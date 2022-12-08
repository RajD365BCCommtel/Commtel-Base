pageextension 50000 CmtlSimProdOrdrExt extends "Simulated Production Order"
{
    layout
    {
        addafter(Quantity)
        {
            field("Project No."; Rec."Project No.")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                ToolTip = 'Specifies the Project No. of the production order.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}