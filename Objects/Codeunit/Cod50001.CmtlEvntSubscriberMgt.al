#pragma warning disable AA0215
codeunit 50001 "Cmtl Evnt. Subscriber Mgt"
#pragma warning restore AA0215
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Report, Report::"Replan Production Order", 'OnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify', '', false, false)]
    local procedure CmtlOnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify(var ProdOrder: Record "Production Order"; MainProdOrder: Record "Production Order"; ProdOrderComp: Record "Prod. Order Component")
    var
        ProdOrdrMgt: Codeunit "Cmtl Prod. Ordr Mgt";
    begin
        if (MainProdOrder.Status IN [MainProdOrder.Status::"Firm Planned", MainProdOrder.Status::Released]) then begin
            ProdOrder.Validate("Parent Prod Order No.", MainProdOrder."No.");
            ProdOrder.Validate("Project No.", MainProdOrder."Project No.");
            ProdOrder.Validate("Shelter Id", MainProdOrder."Shelter Id");
            ProdOrder.Validate("Shelter Name", MainProdOrder."Shelter Name");
            ProdOrder.Validate(Site, MainProdOrder.Site);
            ProdOrder.validate("RSS No.", MainProdOrder."RSS No.");
            ProdOrder.UpdateIndentation();
            ProdOrdrMgt.CalcPresentationOrder(ProdOrder);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitHeaderDefaults', '', false, false)]
    local procedure OnAfterInitHeaderDefaults(VAR PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        PurchLine."Is Requisition" := PurchHeader."Is Requisition";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure CmtlOnAfterGetNoSeriesCode(var PurchHeader: Record "Purchase Header"; PurchSetup: Record "Purchases & Payables Setup"; var NoSeriesCode: Code[20])
    begin
        if PurchHeader."Document Type" = PurchHeader."Document Type"::Quote then
            if PurchHeader."Is Requisition" then
                NoSeriesCode := PurchSetup."Purch. Requisition Nos.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnCreatePurchHeaderOnBeforePurchOrderHeaderInsert', '', false, false)]
    local procedure CmtlOnCreatePurchHeaderOnBeforePurchOrderHeaderInsert(var PurchOrderHeader: Record "Purchase Header"; var PurchHeader: Record "Purchase Header")
    begin
        if not PurchHeader."Is Requisition" then
            exit;

        PurchOrderHeader."Requisition No." := PurchHeader."No.";
        PurchOrderHeader."Quote No." := '';
        PurchOrderHeader."Is Requisition" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnBeforeInsertPurchOrderLine', '', false, false)]
    local procedure CmtlOnBeforeInsertPurchOrderLine(var PurchOrderLine: Record "Purchase Line"; PurchOrderHeader: Record "Purchase Header"; PurchQuoteLine: Record "Purchase Line"; PurchQuoteHeader: Record "Purchase Header")
    begin
        if not PurchQuoteHeader."Is Requisition" then
            exit;

        PurchOrderLine."Requisition No." := PurchQuoteLine."Document No.";
        PurchOrderLine."Requisition Line No." := PurchQuoteLine."Line No.";
        PurchOrderLine."Is Requisition" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', true, true)]
    local procedure CmtlOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
    begin

    end;

    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnBeforeGetDocumentTypeAndNumber', '', true, true)]
    local procedure CmtlOnBeforeGetDocumentTypeAndNumber(VAR NotificationEntry: Record "Notification Entry"; VAR RecRef: RecordRef; VAR DocumentType: Text; VAR DocumentNo: Text; VAR IsHandled: Boolean)
    VAR
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        PurchReqTxt: Label 'Purchase Requisition', Comment = '%1';
    begin
        If RecRef.NUMBER = DATABASE::"Purchase Header" then begin
            FieldRef2 := RecRef.Field(50001);
            if Format(FieldRef2.Value) = 'Yes' then begin
                DocumentType := PurchReqTxt;
                FieldRef := RecRef.FIELD(3);
                DocumentNo := FORMAT(FieldRef.VALUE);
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnBeforeArchivePurchaseQuote', '', false, false)]
    local procedure CmtlOnBeforeArchivePurchaseQuote(var PurchaseHeader: Record "Purchase Header"; PurchaseOrderHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        PurchSetup.Get();

        if not PurchaseHeader."Is Requisition" then
            exit;

        case PurchSetup."Archive Requisitions" of
            PurchSetup."Archive Requisitions"::Always:
                ArchiveManagement.ArchPurchDocumentNoConfirm(PurchaseHeader);
            PurchSetup."Archive Requisitions"::Question:
                ArchiveManagement.ArchivePurchDocument(PurchaseHeader);
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnBeforeCreateMailAndDispatch', '', false, false)]
    local procedure OnBeforeCreateMailAndDispatch(var NotificationEntry: Record "Notification Entry"; var MailSubject: Text; var Email: Text; var IsHandled: Boolean)
    begin
        GetCustomNoteBody(NotificationEntry, MailSubject);
    end;

    local procedure GetCustomNoteBody(var NotificationEntry: Record "Notification Entry"; var Subject: Text)
    var
        NotificationEntryDispatcher: codeunit "Notification Entry Dispatcher";
        NotificationManagement: Codeunit "Notification Management";
        RecRef: RecordRef;
        PRFieldRef: FieldRef;
        DocumentType: Text;
        DocumentNo: Text;
        DocumentName: Text;
        ActionText: Text;
    begin
        NotificationEntryDispatcher.GetTargetRecRef(NotificationEntry, RecRef);
        PRFieldRef := RecRef.Field(50001);
        if Format(PRFieldRef.Value) = 'Yes' then begin
            NotificationManagement.GetDocumentTypeAndNumber(RecRef, DocumentType, DocumentNo);
            DocumentName := 'Purchase Requisition' + ' ' + DocumentNo;
            ActionText := NotificationManagement.GetActionTextFor(NotificationEntry);
            Subject := DocumentName + ' ' + ActionText;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Notification Email", 'OnSetReportFieldPlaceholdersOnBeforeGetWebUrl', '', false, false)]
    local procedure OnSetReportFieldPlaceholdersOnBeforeGetWebUrl(RecRef: RecordRef; var Field1Label: Text; var Field1Value: Text; var Field2Label: Text; var Field2Value: Text; var Field3Label: Text; var Field3Value: Text; var SourceRecRef: RecordRef; var DetailsLabel: Text; var DetailsValue: Text; NotificationEntry: Record "Notification Entry")
    begin
        DetailsValue := DetailsValue + ' | ' + Format(CurrentDateTime());
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnAddNoteOnAfterGetUrl', '', false, false)]
    // local procedure OnAddNoteOnAfterGetUrl(var Link: Text; NotificationEntry: Record "Notification Entry"; RecRefLink: RecordRef)
    // var
    //     FieldRef: FieldRef;
    // begin
    //     If RecRefLink.NUMBER = DATABASE::"Purchase Header" then begin
    //         FieldRef := RecRefLink.Field(50001);
    //         if Format(FieldRef.Value) = 'Yes' then
    //             Link := GETURL(DEFAULTCLIENTTYPE, COMPANYNAME, OBJECTTYPE::Page, Page::"Cmtl Purchase Requisition", RecRefLink, TRUE);
    //     end;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnBeforeChangeStatusOnProdOrder', '', false, false)]
    // local procedure CmtlOnBeforeChangeStatusOnProdOrder(var ProductionOrder: Record "Production Order"; NewStatus: Option Quote,Planned,"Firm Planned",Released,Finished; var IsHandled: Boolean; NewPostingDate: Date; NewUpdateUnitCost: Boolean)
    // var
    //     ChangeStatusErr: Label 'You can not Change Status for Child or Subchild ,Status Change can be applicable only for Parent Production Order', Comment = '';
    // begin
    //     if IsHandled then
    //         exit;

    //     if (ProductionOrder.Status = ProductionOrder.Status::"Firm Planned") AND (NewStatus = NewStatus::Released) then
    //         if (ProductionOrder."Parent Prod Order No." <> '') AND (ProductionOrder.Indentation <> 0) then
    //             Error(ChangeStatusErr);
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnAfterChangeStatusOnProdOrder', '', false, false)]
    // local procedure OnAfterChangeStatusOnProdOrder(var ProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order"; NewStatus: Enum "Production Order Status"; NewPostingDate: Date; NewUpdateUnitCost: Boolean; var SuppressCommit: Boolean)
    // var
    // begin
    //     Message('ProdOrder = %1 & ToProdOrder = %2', ProdOrder."No.", ToProdOrder."No.");
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnAfterTransProdOrder', '', false, false)]
    // local procedure OnAfterTransProdOrder(var FromProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order")
    // var
    //     ProdOrder: Record "Production Order";
    // begin
    //     ProdOrder.SetRange("Parent Prod Order No.", FromProdOrder."No.");
    //     if ProdOrder.FindSet() then
    //         repeat

    //         until ProdOrder.Next() = 0;
    // end;

}