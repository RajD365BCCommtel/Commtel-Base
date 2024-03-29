#pragma warning disable AA0215
pageextension 50015 "CmtlPostedPurchInvExt" extends "Posted Purchase Invoice"
#pragma warning restore AA0215
{
    layout
    {
        addafter("Order No.")
        {
            field("Requisition No."; Rec."Requisition No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the Purch. Requisition No. of the production Quotes.';
            }
            field("Purpose of Purchase"; Rec."Purpose of Purchase")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies Purpose of Purchase.';
            }
            field("Within Budget"; Rec."Within Budget")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies Within Budget.';
            }
        }
    }
}