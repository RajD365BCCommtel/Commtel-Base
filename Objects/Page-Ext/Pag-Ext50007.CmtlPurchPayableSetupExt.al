#pragma warning disable AA0215
pageextension 50007 "CmtlPurchPayableSetupExt" extends "Purchases & Payables Setup"
#pragma warning restore AA0215
{
    layout
    {
        addafter("Quote Nos.")
        {
            field("Purch. Requisition Nos."; Rec."Purch. Requisition Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Purch. Requisition Nos.';
            }
        }
        addbefore("Archive Quotes")
        {
            field("Archive Requisitions"; Rec."Archive Requisitions")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if you want to archive purchase requisitions when they are deleted..';
            }
        }
    }
}