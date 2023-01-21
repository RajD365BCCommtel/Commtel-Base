#pragma warning disable AA0215
codeunit 50004 "Cmtl Purch.-Req to Quote"
#pragma warning restore AA0215
{
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        Vend: Record Vendor;
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        RecordLinkManagement: Codeunit "Record Link Management";
        ShouldRedistributeInvoiceAmount: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeRun(Rec);

        Rec.TestField("Document Type", Rec."Document Type"::Quote);
        ShouldRedistributeInvoiceAmount := PurchCalcDiscByType.ShouldRedistributeInvoiceDiscountAmount(Rec);

        Rec.CheckPurchasePostRestrictions();

        Vend.Get(Rec."Buy-from Vendor No.");
        Vend.CheckBlockedVendOnDocs(Vend, false);

        Rec.ValidatePurchaserOnPurchHeader(Rec, true, false);

        Rec.CheckForBlockedLines();

        CreatePurchHeader(Rec, Vend."Prepayment %");

        TransferReqToQuoteLines(PurchReqLine, Rec, PurchQuoteLine, PurchQuoteHeader, Vend);
        OnAfterInsertAllPurchQuoteLines(PurchQuoteLine, Rec);

        PurchSetup.Get();
        ArchivePurchaseQuote(Rec);

        if PurchSetup."Default Posting Date" = PurchSetup."Default Posting Date"::"No Date" then begin
            PurchQuoteHeader."Posting Date" := 0D;
            PurchQuoteHeader.Modify();
        end;

        PurchCommentLine.CopyComments(Rec."Document Type".AsInteger(), PurchQuoteHeader."Document Type".AsInteger(), Rec."No.", PurchQuoteHeader."No.");
        RecordLinkManagement.CopyLinks(Rec, PurchQuoteHeader);

        AssignItemCharges(Rec."Document Type", Rec."No.", PurchQuoteHeader."Document Type", PurchQuoteHeader."No.");

        ApprovalsMgmt.CopyApprovalEntryQuoteToOrder(Rec.RecordId, PurchQuoteHeader."No.", PurchQuoteHeader.RecordId);

        IsHandled := false;
        OnBeforeDeletePurchReq(Rec, PurchQuoteHeader, IsHandled);
        if not IsHandled then begin
            ApprovalsMgmt.DeleteApprovalEntries(Rec.RecordId);
            PurchCommentLine.DeleteComments(Rec."Document Type".AsInteger(), Rec."No.");
            Rec.DeleteLinks();
            Rec.Delete();
            PurchReqLine.DeleteAll();
        end;

        if not ShouldRedistributeInvoiceAmount then
            PurchCalcDiscByType.ResetRecalculateInvoiceDisc(PurchQuoteHeader);

        OnAfterRun(Rec, PurchQuoteHeader);
    end;

    var
        PurchReqLine: Record "Purchase Line";
        PurchQuoteHeader: Record "Purchase Header";
        PurchQuoteLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        PrepmtMgt: Codeunit "Prepayment Mgt.";

    local procedure CreatePurchHeader(PurchHeader: Record "Purchase Header"; PrepmtPercent: Decimal)
    begin
        OnBeforeCreatePurchHeader(PurchHeader);

        with PurchHeader do begin
            PurchQuoteHeader := PurchHeader;
            PurchQuoteHeader."Document Type" := PurchQuoteHeader."Document Type"::Quote;
            PurchQuoteHeader."No. Printed" := 0;
            PurchQuoteHeader.Status := PurchQuoteHeader.Status::Open;
            PurchQuoteHeader."No." := '';
            PurchQuoteHeader."Is Requisition" := false;
            PurchQuoteHeader."Requisition No." := "No.";

            OnCreatePurchHeaderOnBeforeInitRecord(PurchQuoteHeader, PurchHeader);
            PurchQuoteHeader.InitRecord();

            PurchQuoteLine.LockTable();
            OnCreatePurchHeaderOnBeforePurchQuoteHeaderInsert(PurchQuoteHeader, PurchHeader);
            PurchQuoteHeader.Insert(true);
            OnCreatePurchHeaderOnAfterPurchQuoteHeaderInsert(PurchQuoteHeader, PurchHeader);

            PurchQuoteHeader."Order Date" := "Order Date";
            if "Posting Date" <> 0D then
                PurchQuoteHeader."Posting Date" := "Posting Date";

            PurchQuoteHeader.InitFromPurchHeader(PurchHeader);
            OnCreatePurchHeaderOnAfterInitFromPurchHeader(PurchQuoteHeader, PurchHeader);
            PurchQuoteHeader."Inbound Whse. Handling Time" := "Inbound Whse. Handling Time";

            PurchQuoteHeader."Prepayment %" := PrepmtPercent;
            if PurchQuoteHeader."Posting Date" = 0D then
                PurchQuoteHeader."Posting Date" := WorkDate();
            OnCreatePurchHeaderOnBeforePurchQuoteHeaderModify(PurchQuoteHeader, PurchHeader);
            PurchQuoteHeader.Modify();
        end;

        OnAfterCreatePurchHeader(PurchQuoteHeader, PurchHeader);
    end;

    local procedure ArchivePurchaseQuote(var PurchaseHeader: Record "Purchase Header")
    var
        ArchiveManagement: Codeunit ArchiveManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeArchivePurchaseReq(PurchaseHeader, PurchQuoteHeader, IsHandled);
        if IsHandled then
            exit;

        case PurchSetup."Archive Requisitions" of
            PurchSetup."Archive Requisitions"::Always:
                ArchiveManagement.ArchPurchDocumentNoConfirm(PurchaseHeader);
            PurchSetup."Archive Requisitions"::Question:
                ArchiveManagement.ArchivePurchDocument(PurchaseHeader);
        end;
    end;

    local procedure AssignItemCharges(FromDocType: Enum "Purchase Document Type"; FromDocNo: Code[20]; ToDocType: Enum "Purchase Applies-to Document Type"; ToDocNo: Code[20])
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.Reset();
        ItemChargeAssgntPurch.SetRange("Document Type", FromDocType);
        ItemChargeAssgntPurch.SetRange("Document No.", FromDocNo);
        while ItemChargeAssgntPurch.FindFirst() do begin
            ItemChargeAssgntPurch.Delete();
            ItemChargeAssgntPurch."Document Type" := PurchQuoteHeader."Document Type";
            ItemChargeAssgntPurch."Document No." := PurchQuoteHeader."No.";
            if not (ItemChargeAssgntPurch."Applies-to Doc. Type" in
                    [ItemChargeAssgntPurch."Applies-to Doc. Type"::Receipt,
                     ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Shipment"])
            then begin
                ItemChargeAssgntPurch."Applies-to Doc. Type" := ToDocType;
                ItemChargeAssgntPurch."Applies-to Doc. No." := ToDocNo;
            end;
            ItemChargeAssgntPurch.Insert();
        end;
    end;

    procedure GetPurchQuoteHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader := PurchQuoteHeader;
    end;

    local procedure TransferReqToQuoteLines(var PurchReqLine: Record "Purchase Line"; var PurchReqHeader: Record "Purchase Header"; var PurchQuoteLine: Record "Purchase Line"; var PurchQuoteHeader: Record "Purchase Header"; Vend: Record Vendor)
    var
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        IsHandled: Boolean;
    begin
        PurchReqLine.SetRange("Document Type", PurchReqHeader."Document Type");
        PurchReqLine.SetRange("Document No.", PurchReqHeader."No.");
        OnTransferReqToQuoteLinesOnAfterPurchReqLineSetFilters(PurchReqLine, PurchReqHeader, PurchQuoteHeader);
        if PurchReqLine.FindSet() then
            repeat
                IsHandled := false;
                OnBeforeTransferReqLineToQuoteLineLoop(PurchReqLine, PurchReqHeader, PurchQuoteHeader, IsHandled);
                if not IsHandled then begin
                    PurchQuoteLine := PurchReqLine;
                    PurchQuoteLine."Document Type" := PurchQuoteHeader."Document Type";
                    PurchQuoteLine."Document No." := PurchQuoteHeader."No.";
                    PurchQuoteLine."Is Requisition" := false;
                    PurchQuoteLine."Requisition No." := PurchReqHeader."No.";
                    PurchQuoteLine."Requisition Line No." := PurchReqLine."Line No.";
                    PurchLineReserve.TransferPurchLineToPurchLine(
                      PurchReqLine, PurchQuoteLine, PurchReqLine."Outstanding Qty. (Base)");
                    PurchQuoteLine."Shortcut Dimension 1 Code" := PurchReqLine."Shortcut Dimension 1 Code";
                    PurchQuoteLine."Shortcut Dimension 2 Code" := PurchReqLine."Shortcut Dimension 2 Code";
                    PurchQuoteLine."Dimension Set ID" := PurchReqLine."Dimension Set ID";
                    PurchQuoteLine."Transaction Type" := PurchQuoteHeader."Transaction Type";
                    if Vend."Prepayment %" <> 0 then
                        PurchQuoteLine."Prepayment %" := Vend."Prepayment %";
                    PrepmtMgt.SetPurchPrepaymentPct(PurchQuoteLine, PurchQuoteHeader."Posting Date");
                    ValidatePurchQuoteLinePrepaymentPct(PurchQuoteLine);
                    PurchQuoteLine.DefaultDeferralCode();
                    OnBeforeInsertPurchQuoteLine(PurchQuoteLine, PurchQuoteHeader, PurchReqLine, PurchReqHeader);
                    PurchQuoteLine.Insert();
                    OnAfterInsertPurchQuoteLine(PurchReqLine, PurchQuoteLine);
                    PurchLineReserve.VerifyQuantity(PurchQuoteLine, PurchReqLine);
                    OnTransferReqToQuoteLinesOnAfterVerifyQuantity(PurchQuoteLine, PurchQuoteHeader, PurchReqLine, PurchQuoteHeader);
                end;
            until PurchReqLine.Next() = 0;
    end;

    local procedure ValidatePurchQuoteLinePrepaymentPct(var PurchQuoteLine: Record "Purchase Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidatePurchQuoteLinePrepaymentPct(PurchQuoteLine, IsHandled);
        if IsHandled then
            exit;

        PurchQuoteLine.Validate("Prepayment %");
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(var PurchaseHeader: Record "Purchase Header"; PurchQuoteHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeArchivePurchaseReq(var PurchaseHeader: Record "Purchase Header"; PurchaseOrderHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePurchHeader(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeletePurchReq(var ReqPurchHeader: Record "Purchase Header"; var OrderPurchHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchQuoteLine(var PurchQuoteLine: Record "Purchase Line"; PurchQuoteHeader: Record "Purchase Header"; PurchReqLine: Record "Purchase Line"; PurchReqHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPurchQuoteLine(var PurchaseReqLine: Record "Purchase Line"; var PurchaseOrderLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAllPurchQuoteLines(var PurchQuoteLine: Record "Purchase Line"; PurchReqHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferReqLineToQuoteLineLoop(var PurchReqLine: Record "Purchase Line"; var PurchReqHeader: Record "Purchase Header"; var PurchQuoteHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePurchQuoteLinePrepaymentPct(var PurchQuoteLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnBeforeInitRecord(var PurchQuoteHeader: Record "Purchase Header"; var PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnAfterInitFromPurchHeader(var PurchQuoteHeader: Record "Purchase Header"; PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnBeforePurchQuoteHeaderInsert(var PurchQuoteHeader: Record "Purchase Header"; var PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnAfterPurchQuoteHeaderInsert(var PurchQuoteHeader: Record "Purchase Header"; BlanketOrderPurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnBeforePurchQuoteHeaderModify(var PurchQuoteHeader: Record "Purchase Header"; var PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchHeader(var PurchQuoteHeader: Record "Purchase Header"; PurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransferReqToQuoteLinesOnAfterPurchReqLineSetFilters(var PurchReqLine: Record "Purchase Line"; var PurchReqHeader: Record "Purchase Header"; PurchQuoteHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransferReqToQuoteLinesOnAfterVerifyQuantity(var PurchQuoteLine: Record "Purchase Line"; PurchQuoteHeader: Record "Purchase Header"; PurchReqLine: Record "Purchase Line"; PurchReqHeader: Record "Purchase Header")
    begin
    end;
}

