#pragma warning disable AW0006
#pragma warning disable AA0215
report 50001 "Cmtl Copy Purchase Document"
#pragma warning restore AA0215
#pragma warning restore AW0006
{
    Caption = 'Copy Purchase Document';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocumentType; NewDocType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies the type of document that is processed by the report or batch job.';

                        trigger OnValidate()
                        begin
                            FromDocNo := '';
                            ValidateDocNo();
                        end;
                    }
                    field(DocumentNo; FromDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo();
                        end;

                        trigger OnValidate()
                        begin
                            ValidateDocNo();
                        end;
                    }
                    field(DocNoOccurrence; FromDocNoOccurrence)
                    {
                        ApplicationArea = Basic, Suite;
                        BlankZero = true;
                        Caption = 'Doc. No. Occurrence';
                        Editable = false;
                        ToolTip = 'Specifies the number of times the No. value has been used in the number series.';
                    }
                    field(DocVersionNo; FromDocVersionNo)
                    {
                        ApplicationArea = Basic, Suite;
                        BlankZero = true;
                        Caption = 'Version No.';
                        Editable = false;
                        ToolTip = 'Specifies the version of the document to be copied.';
                    }
                    field(BuyfromVendorNo; FromPurchHeader."Buy-from Vendor No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Buy-from Vendor No.';
                        Editable = false;
                        ToolTip = 'Specifies the vendor according to the values in the Document No. and Document Type fields.';
                    }
                    field(BuyfromVendorName; FromPurchHeader."Buy-from Vendor Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Buy-from Vendor Name';
                        Editable = false;
                        ToolTip = 'Specifies the vendor according to the values in the Document No. and Document Type fields.';
                    }
                    field(IncludeHeader_Options; IncludeHeader)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Header';
                        ToolTip = 'Specifies if you also want to copy the information from the document header. When you copy quotes, if the posting date field of the new document is empty, the work date is used as the posting date of the new document.';

                        trigger OnValidate()
                        begin
                            ValidateIncludeHeader();
                        end;
                    }
                    field(RecalculateLines; RecalculateLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recalculate Lines';
                        ToolTip = 'Specifies that lines are recalculate and inserted on the purchase document you are creating. The batch job retains the item numbers and item quantities but recalculates the amounts on the lines based on the vendor information on the new document header. In this way, the batch job accounts for item prices and discounts that are specifically linked to the vendor on the new header.';

                        trigger OnValidate()
                        begin
                            if (FromDocType = FromDocType::"Posted Receipt") or (FromDocType = FromDocType::"Posted Return Shipment") then
                                RecalculateLines := true;
                        end;
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date of the entry.';
                    }
                    field(ReplacePostingDate; ReplacePostDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies that you want to replace the posting date with a new date when the batch job copies the document including the date.';

                        trigger OnValidate()
                        begin
                            if ReplacePostDate then
                                ReplaceDocDate := ReplacePostDate;
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replace Document Date';
                        ToolTip = 'Specifies that you want to replace the document date with a new date when the batch job copies the document including the date.';

                        trigger OnValidate()
                        begin
                            if ReplacePostDate then
                                ReplaceDocDate := ReplacePostDate;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            OnBeforeOpenPage(FromDocNo, FromDocType);
            if FromDocNo <> '' then begin
                case FromDocType of
                    FromDocType::Quote:
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::Quote, FromDocNo) then
                            ;
                    FromDocType::"Blanket Order":
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::"Blanket Order", FromDocNo) then
                            ;
                    FromDocType::Order:
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::Order, FromDocNo) then
                            ;
                    FromDocType::Invoice:
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::Invoice, FromDocNo) then
                            ;
                    FromDocType::"Return Order":
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::"Return Order", FromDocNo) then
                            ;
                    FromDocType::"Credit Memo":
                        if FromPurchHeader.Get(FromPurchHeader."Document Type"::"Credit Memo", FromDocNo) then
                            ;
                    FromDocType::"Posted Receipt":
                        if FromPurchRcptHeader.Get(FromDocNo) then
                            FromPurchHeader.TransferFields(FromPurchRcptHeader);
                    FromDocType::"Posted Invoice":
                        if FromPurchInvHeader.Get(FromDocNo) then
                            FromPurchHeader.TransferFields(FromPurchInvHeader);
                    FromDocType::"Posted Return Shipment":
                        if FromReturnShptHeader.Get(FromDocNo) then
                            FromPurchHeader.TransferFields(FromReturnShptHeader);
                    FromDocType::"Posted Credit Memo":
                        if FromPurchCrMemoHeader.Get(FromDocNo) then
                            FromPurchHeader.TransferFields(FromPurchCrMemoHeader);
                    FromDocType::"Arch. Order":
                        if FromPurchHeaderArchive.Get(FromPurchHeaderArchive."Document Type"::Order, FromDocNo, FromDocNoOccurrence, FromDocVersionNo) then
                            FromPurchHeader.TransferFields(FromPurchHeaderArchive);
                    FromDocType::"Arch. Quote":
                        if FromPurchHeaderArchive.Get(FromPurchHeaderArchive."Document Type"::Quote, FromDocNo, FromDocNoOccurrence, FromDocVersionNo) then
                            FromPurchHeader.TransferFields(FromPurchHeaderArchive);
                    FromDocType::"Arch. Blanket Order":
                        if FromPurchHeaderArchive.Get(FromPurchHeaderArchive."Document Type"::"Blanket Order", FromDocNo, FromDocNoOccurrence, FromDocVersionNo) then
                            FromPurchHeader.TransferFields(FromPurchHeaderArchive);
                    FromDocType::"Arch. Return Order":
                        if FromPurchHeaderArchive.Get(FromPurchHeaderArchive."Document Type"::"Return Order", FromDocNo, FromDocNoOccurrence, FromDocVersionNo) then
                            FromPurchHeader.TransferFields(FromPurchHeaderArchive);
                end;
                if FromPurchHeader."No." = '' then
                    FromDocNo := '';
            end;
            ValidateDocNo();

            OnAfterOpenPage();
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin
        OnBeforePreReport();
        if (NewDocType = NewDocType::Requisition) OR (NewDocType = NewDocType::"Arch. Requisition") then begin
            IF (NewDocType = NewDocType::Requisition) THEN
                FromDocType := FromDocType::Quote;
            IF (NewDocType = NewDocType::"Arch. Requisition") then
                FromDocType := FromDocType::"Arch. Quote";
            IsRequisition := true;
        end else
            FromDocType := NewDocType.AsInteger() - 1;

        PurchSetup.Get();
        CopyDocMgt.SetProperties(
          IncludeHeader, RecalculateLines, false, false, false, PurchSetup."Exact Cost Reversing Mandatory", false);
        CopyDocMgt.SetArchDocVal(FromDocNoOccurrence, FromDocVersionNo);

        OnPreReportOnBeforeCopyPurchaseDoc(CopyDocMgt, CurrReport.UseRequestPage(), IncludeHeader, RecalculateLines);

        CopyDocMgt.CopyPurchDoc(FromDocType, FromDocNo, PurchHeader);

        with PurchHeader do begin
            if ReplacePostDate or ReplaceDocDate then begin
                if ReplacePostDate then
                    Validate("Posting Date", PostingDate);
                if ReplaceDocDate then
                    Validate("Document Date", PostingDate);
                Modify();
            end;
            GLSetup.Get();
            if ("Document Type" = "Document Type"::"Credit Memo") and
               (GLSetup.GSTEnabled(FromPurchHeader."Document Date"))
            then begin
                case FromDocType of
                    FromDocType::Quote, FromDocType::"Blanket Order", FromDocType::Order,
                    FromDocType::Invoice, FromDocType::"Credit Memo", FromDocType::"Return Order":
                        begin
                            "Adjustment Applies-to" := FromPurchHeader."No.";
                            "BAS Adjustment" := CheckBASPeriod("Document Date", FromPurchHeader."Document Date");
                        end;
                    FromDocType::"Posted Receipt":
                        begin
                            "Adjustment Applies-to" := FromPurchRcptHeader."No.";
                            "BAS Adjustment" := CheckBASPeriod("Document Date", FromPurchRcptHeader."Document Date");
                        end;
                    FromDocType::"Posted Invoice":
                        begin
                            "Adjustment Applies-to" := FromPurchInvHeader."No.";
                            "BAS Adjustment" := CheckBASPeriod("Document Date", FromPurchInvHeader."Document Date");
                        end;
                    FromDocType::"Posted Credit Memo":
                        begin
                            "Adjustment Applies-to" := FromPurchCrMemoHeader."No.";
                            "BAS Adjustment" := CheckBASPeriod("Document Date", FromPurchCrMemoHeader."Document Date");
                        end;
                    FromDocType::"Posted Return Shipment":
                        begin
                            "Adjustment Applies-to" := FromReturnShptHeader."No.";
                            "BAS Adjustment" := CheckBASPeriod("Document Date", FromReturnShptHeader."Document Date");
                        end;
                end;
                Modify();
            end;
        end;
        OnAfterOnPreReport(FromDocType, FromDocNo, PurchHeader);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        BASManagement: Codeunit "BAS Management";
        ReplaceDocDate: Boolean;
        ReplacePostDate: Boolean;
        PostingDate: Date;

        Text000: Label 'The price information may not be reversed correctly, if you copy a %1. If possible, copy a %2 instead or use %3 functionality.';
        Text001: Label 'Undo Receipt';
        Text002: Label 'Undo Return Shipment';

    protected var
        FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        FromPurchInvHeader: Record "Purch. Inv. Header";
        FromPurchRcptHeader: Record "Purch. Rcpt. Header";
        FromPurchHeader: Record "Purchase Header";
        PurchHeader: Record "Purchase Header";
        FromPurchHeaderArchive: Record "Purchase Header Archive";
        PurchSetup: Record "Purchases & Payables Setup";
        FromReturnShptHeader: Record "Return Shipment Header";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        FromDocNo: Code[20];
        FromDocType: Enum "Purchase Document Type From";
        NewDocType: Enum "Cmtl Purchase Document Type";
        FromDocNoOccurrence: Integer;
        FromDocVersionNo: Integer;
        IsRequisition: Boolean;


    procedure SetPurchHeader(var NewPurchHeader: Record "Purchase Header")
    begin
        NewPurchHeader.TestField("No.");
        PurchHeader := NewPurchHeader;
    end;

    local procedure ValidateDocNo()
    begin
        Clear(IsRequisition);
        if (NewDocType = NewDocType::Requisition) OR (NewDocType = NewDocType::"Arch. Requisition") then begin
            IF (NewDocType = NewDocType::Requisition) THEN
                FromDocType := FromDocType::Quote;
            IF (NewDocType = NewDocType::"Arch. Requisition") then
                FromDocType := FromDocType::"Arch. Quote";
            IsRequisition := true;
        end else
            FromDocType := NewDocType.AsInteger() - 1;

        if FromDocNo = '' then begin
            FromPurchHeader.Init();
            FromDocNoOccurrence := 0;
            FromDocVersionNo := 0;
        end else
            if FromDocNo <> FromPurchHeader."No." then begin
                FromPurchHeader.Init();
                case FromDocType of
                    FromDocType::Quote,
                    FromDocType::"Blanket Order",
                    FromDocType::Order,
                    FromDocType::Invoice,
                    FromDocType::"Return Order",
                    FromDocType::"Credit Memo":
                        FromPurchHeader.Get(CopyDocMgt.GetPurchaseDocumentType(FromDocType), FromDocNo);
                    FromDocType::"Posted Receipt":
                        begin
                            FromPurchRcptHeader.Get(FromDocNo);
                            FromPurchHeader.TransferFields(FromPurchRcptHeader);
                            OnValidateDocNoOnAfterTransferFieldsFromPurchRcptHeader(FromPurchHeader, FromPurchRcptHeader);
                            if PurchHeader."Document Type" in
                               [PurchHeader."Document Type"::"Return Order", PurchHeader."Document Type"::"Credit Memo"]
                            then
                                Message(Text000, FromDocType, "Cmtl Purchase Document Type"::"Posted Invoice", Text001);
                        end;
                    FromDocType::"Posted Invoice":
                        begin
                            FromPurchInvHeader.Get(FromDocNo);
                            FromPurchHeader.TransferFields(FromPurchInvHeader);
                            OnValidateDocNoOnAfterTransferFieldsFromPurchInvHeader(FromPurchHeader, FromPurchInvHeader);
                        end;
                    FromDocType::"Posted Return Shipment":
                        begin
                            FromReturnShptHeader.Get(FromDocNo);
                            FromPurchHeader.TransferFields(FromReturnShptHeader);
                            OnValidateDocNoOnAfterTransferFieldsFromReturnShipmentHeader(FromPurchHeader, FromReturnShptHeader);
                            if PurchHeader."Document Type" in
                               [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice]
                            then
                                Message(Text000, FromDocType, "Cmtl Purchase Document Type"::"Posted Credit Memo", Text002);
                        end;
                    FromDocType::"Posted Credit Memo":
                        begin
                            FromPurchCrMemoHeader.Get(FromDocNo);
                            FromPurchHeader.TransferFields(FromPurchCrMemoHeader);
                            OnValidateDocNoOnAfterTransferFieldsFromPurchCrMemoHeader(FromPurchHeader, FromPurchCrMemoHeader);
                        end;
                    FromDocType::"Arch. Quote",
                    FromDocType::"Arch. Order",
                    FromDocType::"Arch. Blanket Order",
                    FromDocType::"Arch. Return Order":
                        begin
                            FindFromPurchHeaderArchive();
                            FromPurchHeader.TransferFields(FromPurchHeaderArchive);
                        end;
                end;
            end;
        FromPurchHeader."No." := '';

        IncludeHeader :=
          (FromDocType in [FromDocType::"Posted Invoice", FromDocType::"Posted Credit Memo"]) and
          ((FromDocType = FromDocType::"Posted Credit Memo") <>
           (PurchHeader."Document Type" = PurchHeader."Document Type"::"Credit Memo")) and
          (PurchHeader."Buy-from Vendor No." in [FromPurchHeader."Buy-from Vendor No.", '']);

        OnBeforeValidateIncludeHeader(IncludeHeader, FromDocType.AsInteger(), PurchHeader, FromPurchHeader);
        ValidateIncludeHeader();
    end;

    local procedure FindFromPurchHeaderArchive()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindFromPurchHeaderArchive(FromPurchHeaderArchive, FromDocType, FromDocNo, FromDocNoOccurrence, FromDocVersionNo, IsHandled);
        if IsHandled then
            exit;

        if not FromPurchHeaderArchive.Get(
            CopyDocMgt.GetPurchaseDocumentType(FromDocType), FromDocNo, FromDocNoOccurrence, FromDocVersionNo)
        then begin
            FromPurchHeaderArchive.SetRange("No.", FromDocNo);
            if FromPurchHeaderArchive.FindLast() then begin
                FromDocNoOccurrence := FromPurchHeaderArchive."Doc. No. Occurrence";
                FromDocVersionNo := FromPurchHeaderArchive."Version No.";
            end;
        end;
    end;

    local procedure LookupDocNo()
    begin
        OnBeforeLookupDocNo(PurchHeader, FromDocType, FromDocNo);
        if (NewDocType = NewDocType::Requisition) OR (NewDocType = NewDocType::"Arch. Requisition") then begin
            IF (NewDocType = NewDocType::Requisition) THEN
                FromDocType := FromDocType::Quote;
            IF (NewDocType = NewDocType::"Arch. Requisition") then
                FromDocType := FromDocType::"Arch. Quote";
            IsRequisition := true;
        end else
            FromDocType := NewDocType.AsInteger() - 1;

        case FromDocType of
            FromDocType::Quote,
            FromDocType::"Blanket Order",
            FromDocType::Order,
            FromDocType::Invoice,
            FromDocType::"Return Order",
            FromDocType::"Credit Memo":
                LookupPurchDoc();
            FromDocType::"Posted Receipt":
                LookupPostedReceipt();
            FromDocType::"Posted Invoice":
                LookupPostedInvoice();
            FromDocType::"Posted Return Shipment":
                LookupPostedReturn();
            FromDocType::"Posted Credit Memo":
                LookupPostedCrMemo();
            FromDocType::"Arch. Quote",
            FromDocType::"Arch. Order",
            FromDocType::"Arch. Blanket Order",
            FromDocType::"Arch. Return Order":
                LookupPurchArchive();
        end;
        ValidateDocNo();
    end;

    local procedure LookupPurchDoc()
    begin
        OnBeforeLookupPurchDoc(FromPurchHeader, PurchHeader);

        FromPurchHeader.FilterGroup := 0;
        FromPurchHeader.SetRange("Document Type", CopyDocMgt.GetPurchaseDocumentType(FromDocType));
        if PurchHeader."Document Type" = CopyDocMgt.GetPurchaseDocumentType(FromDocType) then
            FromPurchHeader.SetFilter("No.", '<>%1', PurchHeader."No.");
        FromPurchHeader.SetRange("Is Requisition", IsRequisition);
        FromPurchHeader.FilterGroup := 2;
        FromPurchHeader."Document Type" := CopyDocMgt.GetPurchaseDocumentType(FromDocType);
        FromPurchHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromPurchHeader.SetCurrentKey("Document Type", "Buy-from Vendor No.") then begin
                FromPurchHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromPurchHeader.Find('=><') then;
            end;
        if IsRequisition then begin
            if PAGE.RunModal(Page::"Cmtl Purchase Requisition List", FromPurchHeader) = ACTION::LookupOK then
                FromDocNo := FromPurchHeader."No.";
        end else
            if PAGE.RunModal(0, FromPurchHeader) = ACTION::LookupOK then
                FromDocNo := FromPurchHeader."No.";
    end;

    local procedure LookupPurchArchive()
    begin
        FromPurchHeaderArchive.Reset();
        OnLookupPurchArchiveOnBeforeSetFilters(FromPurchHeaderArchive, PurchHeader);
        FromPurchHeaderArchive.FilterGroup := 0;
        FromPurchHeaderArchive.SetRange("Document Type", CopyDocMgt.GetPurchaseDocumentType(FromDocType));
        //if FromDocType = FromDocType::"Arch. Requisition" then
        //FromPurchHeaderArchive.SetRange("Is Requisition", true);
        FromPurchHeaderArchive.SetRange("Is Requisition", IsRequisition);
        FromPurchHeaderArchive.FilterGroup := 2;
        FromPurchHeaderArchive."Document Type" := CopyDocMgt.GetPurchaseDocumentType(FromDocType);
        FromPurchHeaderArchive."No." := FromDocNo;
        FromPurchHeaderArchive."Doc. No. Occurrence" := FromDocNoOccurrence;
        FromPurchHeaderArchive."Version No." := FromDocVersionNo;
        if (FromDocNo = '') and (PurchHeader."Sell-to Customer No." <> '') then
            if FromPurchHeaderArchive.SetCurrentKey("Document Type", "Sell-to Customer No.") then begin
                FromPurchHeaderArchive."Sell-to Customer No." := PurchHeader."Sell-to Customer No.";
                if FromPurchHeaderArchive.Find('=><') then;
            end;
        if IsRequisition then begin
            if PAGE.RunModal(Page::"Cmtl Purch Requistn Archives", FromPurchHeaderArchive) = ACTION::LookupOK then begin
                FromDocNo := FromPurchHeaderArchive."No.";
                FromDocNoOccurrence := FromPurchHeaderArchive."Doc. No. Occurrence";
                FromDocVersionNo := FromPurchHeaderArchive."Version No.";
                RequestOptionsPage.Update(false);
            end;
        end else
            if PAGE.RunModal(0, FromPurchHeaderArchive) = ACTION::LookupOK then begin
                FromDocNo := FromPurchHeaderArchive."No.";
                FromDocNoOccurrence := FromPurchHeaderArchive."Doc. No. Occurrence";
                FromDocVersionNo := FromPurchHeaderArchive."Version No.";
                RequestOptionsPage.Update(false);
            end;
    end;

    local procedure LookupPostedReceipt()
    var
        IsHandled: Boolean;
    begin
        OnBeforeLookupPostedReceipt(FromPurchRcptHeader, PurchHeader);

        FromPurchRcptHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromPurchRcptHeader.SetCurrentKey("Buy-from Vendor No.") then begin
                FromPurchRcptHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromPurchRcptHeader.Find('=><') then;
            end;

        IsHandled := false;
        OnLookupPostedReceiptOnBeforeOpenPage(PurchHeader, FromPurchRcptHeader, FromDocNo, IsHandled);
        if not IsHandled then
            if PAGE.RunModal(0, FromPurchRcptHeader) = ACTION::LookupOK then
                FromDocNo := FromPurchRcptHeader."No.";
    end;

    local procedure LookupPostedInvoice()
    var
        IsHandled: Boolean;
    begin
        OnBeforeLookupPostedInvoice(FromPurchInvHeader, PurchHeader);

        FromPurchInvHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromPurchInvHeader.SetCurrentKey("Buy-from Vendor No.") then begin
                FromPurchInvHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromPurchInvHeader.Find('=><') then;
            end;
        FromPurchInvHeader.FilterGroup(2);
        FromPurchInvHeader.SetRange("Prepayment Invoice", false);
        FromPurchInvHeader.FilterGroup(0);

        IsHandled := false;
        OnLookupPostedInvoiceOnBeforeOpenPage(PurchHeader, FromPurchInvHeader, FromDocNo, IsHandled);
        if not IsHandled then
            if PAGE.RunModal(0, FromPurchInvHeader) = ACTION::LookupOK then
                FromDocNo := FromPurchInvHeader."No.";
    end;

    local procedure LookupPostedCrMemo()
    var
        IsHandled: Boolean;
    begin
        OnBeforeLookupPostedCrMemo(FromPurchCrMemoHeader, PurchHeader);

        FromPurchCrMemoHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromPurchCrMemoHeader.SetCurrentKey("Buy-from Vendor No.") then begin
                FromPurchCrMemoHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromPurchCrMemoHeader.Find('=><') then;
            end;
        FromPurchCrMemoHeader.FilterGroup(2);
        FromPurchCrMemoHeader.SetRange("Prepayment Credit Memo", false);
        FromPurchCrMemoHeader.FilterGroup(0);

        IsHandled := false;
        OnLookupPostedCrMemoOnBeforeOpenPage(PurchHeader, FromPurchCrMemoHeader, FromDocNo, IsHandled);
        if not IsHandled then
            if PAGE.RunModal(0, FromPurchCrMemoHeader) = ACTION::LookupOK then
                FromDocNo := FromPurchCrMemoHeader."No.";
    end;

    local procedure LookupPostedReturn()
    begin
        OnBeforeLookupPostedReturn(FromReturnShptHeader, PurchHeader);

        FromReturnShptHeader."No." := FromDocNo;
        if (FromDocNo = '') and (PurchHeader."Buy-from Vendor No." <> '') then
            if FromReturnShptHeader.SetCurrentKey("Buy-from Vendor No.") then begin
                FromReturnShptHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
                if FromReturnShptHeader.Find('=><') then;
            end;
        if PAGE.RunModal(0, FromReturnShptHeader) = ACTION::LookupOK then
            FromDocNo := FromReturnShptHeader."No.";
    end;

    protected procedure ValidateIncludeHeader()
    begin
        RecalculateLines :=
          (FromDocType in [FromDocType::"Posted Receipt", FromDocType::"Posted Return Shipment"]) or not IncludeHeader;
        OnAfterValidateIncludeHeader(RecalculateLines, IncludeHeader);
    end;

    procedure SetParameters(NewFromDocType: Enum "Cmtl Purchase Document Type"; NewFromDocNo: Code[20];
                                                NewIncludeHeader: Boolean;
                                                NewRecalcLines: Boolean)
    begin
        FromDocType := NewFromDocType;
        FromDocNo := NewFromDocNo;
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalcLines;
    end;

    local procedure CheckBASPeriod(DocDate: Date; InvDocDate: Date): Boolean
    var
        CompanyInfo: Record "Company Information";
        Date: Record Date;
    begin
        CompanyInfo.Get();
        if InvDocDate < 20000701D then
            exit(false);
        case CompanyInfo."Tax Period" of
            CompanyInfo."Tax Period"::Monthly:
                exit(InvDocDate < CalcDate('<D1-1M>', DocDate));
            CompanyInfo."Tax Period"::Quarterly:
                begin
                    Date.SetRange("Period Type", Date."Period Type"::Quarter);
                    Date.SetFilter("Period Start", '..%1', DocDate);
                    Date.FindLast();
                    exit(InvDocDate < Date."Period Start");
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOpenPage()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnPreReport(PurchDocTypeFrom: Enum "Cmtl Purchase Document Type"; DocNo: Code[20]; var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateIncludeHeader(var RecalculateLines: Boolean; IncludeHeader: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindFromPurchHeaderArchive(var FromPurchHeaderArchive: Record "Purchase Header Archive"; DocType: Enum "Cmtl Purchase Document Type"; DocNo: Code[20]; var DocNoOccurrence: Integer; var DocVersionNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupDocNo(var PurchaseHeader: Record "Purchase Header"; var FromDocType: Enum "Purchase Document Type From"; var FromDocNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPurchDoc(var FromPurchaseHeader: Record "Purchase Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPostedReceipt(var PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPostedInvoice(var FromPurchInvHeader: Record "Purch. Inv. Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPostedCrMemo(var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupPostedReturn(var FromReturnShptHeader: Record "Return Shipment Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenPage(var FromDocNo: Code[20]; var FromDocType: Enum "Purchase Document Type From")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePreReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateIncludeHeader(var DoIncludeHeader: Boolean; DocType: Option; var PurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupPurchArchiveOnBeforeSetFilters(var FromPurchHeaderArchive: Record "Purchase Header Archive"; var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPreReportOnBeforeCopyPurchaseDoc(var CopyDocumentMgt: Codeunit "Copy Document Mgt."; UseRequestPage: Boolean; IncludeHeader: Boolean; RecalculateLines: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateDocNoOnAfterTransferFieldsFromPurchRcptHeader(FromPurchHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateDocNoOnAfterTransferFieldsFromPurchInvHeader(FromPurchHeader: Record "Purchase Header"; FromPurchInvHeader: Record "Purch. Inv. Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateDocNoOnAfterTransferFieldsFromPurchCrMemoHeader(FromPurchHeader: Record "Purchase Header"; FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateDocNoOnAfterTransferFieldsFromReturnShipmentHeader(FromPurchHeader: Record "Purchase Header"; FromReturnShipmentHeader: Record "Return Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupPostedReceiptOnBeforeOpenPage(var PurchHeader: Record "Purchase Header"; var FromPurchRcptHeader: Record "Purch. Rcpt. Header"; var DocNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupPostedInvoiceOnBeforeOpenPage(var PurchHeader: Record "Purchase Header"; var FromPurchInvHeader: Record "Purch. Inv. Header"; var DocNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupPostedCrMemoOnBeforeOpenPage(var PurchHeader: Record "Purchase Header"; var FromPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var DocNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}

