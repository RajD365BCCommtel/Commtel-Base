#pragma warning disable AA0215
tableextension 50003 "CmtlPurchLineExt" extends "Purchase Line"
#pragma warning restore AA0215
{
    fields
    {
        field(50000; "Requisition No."; Code[20])
        {
            Caption = 'Requisition No.';
            DataClassification = ToBeClassified;
        }
        field(50001; "Requisition Line No."; Integer)
        {
            Caption = 'Requisition No.';
            DataClassification = ToBeClassified;
        }
        field(50002; "Is Requisition"; Boolean)
        {
            Caption = 'Is Requisition';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(SK; "Requisition No.", "Requisition Line No.")
        {

        }
    }
}