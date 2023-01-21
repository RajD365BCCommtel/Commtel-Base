#pragma warning disable AA0215
tableextension 50002 "CmtlPurchPayableSetupExt" extends "Purchases & Payables Setup"
#pragma warning restore AA0215
{
    fields
    {
        field(50000; "Purch. Requisition Nos."; Code[20])
        {
            Caption = 'Purch. Requisition Nos.';
            TableRelation = "No. Series";
        }
        field(50001; "Archive Requisitions"; Option)
        {
            Caption = 'Archive Requisitions';
            OptionCaption = 'Never,Question,Always';
            OptionMembers = Never,Question,Always;
        }
    }
}