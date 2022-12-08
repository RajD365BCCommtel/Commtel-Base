pageextension 50003 "CmtlReleaseProdOrdrExt" extends "Released Production Order"
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
            field("Site"; Rec."Site")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                ToolTip = 'Specifies the Site No. of the production order.';
            }
            field("Shelter Id"; Rec."Shelter Id")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                ToolTip = 'Specifies the Shelter Id of the production order.';
            }
            field("Shelter Name"; Rec."Shelter Name")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                ToolTip = 'Specifies the Shelter Name of the production order.';
            }
            field("RSS No."; Rec."RSS No.")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                ToolTip = 'Specifies the RSS No. of the production order.';
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