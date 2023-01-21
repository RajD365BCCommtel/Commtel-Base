#pragma warning disable AA0215
pageextension 50006 "CmtlProdPlannerRoleCenterExt" extends "Production Planner Role Center"
#pragma warning restore AA0215
{
    actions
    {
        modify("Firm Planned Production Orders")
        {
            Visible = false;
        }
        modify("Released Production Orders")
        {
            Visible = false;
        }
        addafter("Firm Planned Production Orders")
        {
            action("CmtlFirm Planned Production Orders")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Firm Planned Production Orders';
                RunObject = Page "Cmtl Firm Planned Prod. Orders";
                ToolTip = 'View completed production orders. ';
            }
            action("Cmtl Released Production Orders")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Released Production Orders';
                RunObject = Page "Cmtl Released Prod Orders";
                ToolTip = 'View the list of released production order that are ready for warehouse activities.';
            }
        }
    }

}