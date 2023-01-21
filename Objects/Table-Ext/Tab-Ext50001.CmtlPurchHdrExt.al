#pragma warning disable AA0215
tableextension 50001 "CmtlPurchHdrExt" extends "Purchase Header"
#pragma warning restore AA0215
{
    fields
    {
        field(50000; "Requisition No."; Code[20])
        {
            Caption = 'Requisition No.';
            DataClassification = ToBeClassified;
        }
        field(50001; "Is Requisition"; Boolean)
        {
            Caption = 'Is Requisition';
            DataClassification = ToBeClassified;
        }
        field(50002; "Within Budget"; Boolean)
        {
            Caption = 'Within Budget';
            DataClassification = ToBeClassified;
        }
        field(50003; "Purpose of Purchase"; Enum "Cmtl Purpose of Purchase")
        {
            Caption = 'Purpose of Purchase';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(SK; "Requisition No.")
        {

        }
        key(SK2; "Is Requisition")
        {

        }
    }
    procedure CopyPurchaseDocument()
    var
        CopyPurchaseDocument: Report "Cmtl Copy Purchase Document";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyPurchaseDocument(Rec, IsHandled);
        if IsHandled then
            exit;

        CopyPurchaseDocument.SetPurchHeader(Rec);
        CopyPurchaseDocument.RunModal();
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean);
    begin
    end;
}