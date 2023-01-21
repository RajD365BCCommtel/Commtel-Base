#pragma warning disable AA0215
tableextension 50007 "CmtlPurchRcptHdrExt" extends "Purch. Rcpt. Header"
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
}