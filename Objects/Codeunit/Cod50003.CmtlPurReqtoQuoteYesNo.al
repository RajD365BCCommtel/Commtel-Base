#pragma warning disable AA0215
codeunit 50003 "CmtlPur. Req to Quote (Yes/No)"
#pragma warning restore AA0215
{
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
    begin
        Rec.TestField("Document Type", Rec."Document Type"::Quote);
        Rec.TestField("Is Requisition", true);

        if not ConfirmManagement.GetResponseOrDefault(ConvertReqToQuoterQst, true) then
            exit;

        IsHandled := false;
        OnBeforePurchReqToQuote(Rec, IsHandled);
        if IsHandled then
            exit;

        PurchReqToQuote.Run(Rec);
        PurchReqToQuote.GetPurchQuoteHeader(PurchQuoteHeader);

        IsHandled := false;
        OnAfterCreatePurchQuote(PurchQuoteHeader, IsHandled);
        if not IsHandled then
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(OpenNewQuoteQst, PurchQuoteHeader."No."), true) then
                PAGE.Run(PAGE::"Purchase Quote", PurchQuoteHeader);
    end;

    var
        ConvertReqToQuoterQst: Label 'Do you want to convert the requisition to an quote?';
        PurchQuoteHeader: Record "Purchase Header";
        PurchReqToQuote: Codeunit "Cmtl Purch.-Req to Quote";
        OpenNewQuoteQst: Label 'The requisition has been converted to quote number %1. Do you want to open the new quote?', Comment = '%1 - No. of new purchase quote.';

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchQuote(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchReqToQuote(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;
}

