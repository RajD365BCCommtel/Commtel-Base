#pragma warning disable AA0215
pageextension 50002 "CmtlFirmPlannedProdOrdrExt" extends "Firm Planned Prod. Order"
#pragma warning restore AA0215
{
    //PromotedActionCategories =
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
            field("Parent Prod Order No."; Rec."Parent Prod Order No.")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies the RSS No. of the production order.';
            }
            field("Presentation Order"; Rec."Presentation Order")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies the Presentation Order of the production order.';
            }
            field(Indentation; Rec.Indentation)
            {
                ApplicationArea = All;
                Importance = Promoted;
                ToolTip = 'Specifies the Indentation of the production order.';
            }

        }
    }

    actions
    {
        modify("Change &Status")
        {
            Visible = false;
        }
        addafter("Change &Status")
        {
            action("Cmtl Change &Status")
            {
                ApplicationArea = All;
                Caption = 'Change &Status';
                Ellipsis = true;
                Image = ChangeStatus;
                ToolTip = 'Change the production order to another status, such as Released.';
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    CurrPage.Update();
                    CODEUNIT.Run(CODEUNIT::"Cmtl Prod. Order Status Mgt.", Rec);
                end;
            }
        }
    }
}