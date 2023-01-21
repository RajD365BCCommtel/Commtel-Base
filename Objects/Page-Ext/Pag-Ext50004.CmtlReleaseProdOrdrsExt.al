#pragma warning disable AA0215
pageextension 50004 "CmtlReleaseProdOrdrsExt" extends "Released Production Orders"
#pragma warning restore AA0215
{
    ObsoleteReason = 'Removed';
    ObsoleteState = Pending;
    ObsoleteTag = 'Removed because of ShowAsTree';
    Caption = 'Removed Content';
    // layout
    // {
    //     addafter(Quantity)
    //     {
    //         field("Project No."; Rec."Project No.")
    //         {
    //             ApplicationArea = Manufacturing;
    //             Importance = Promoted;
    //             ToolTip = 'Specifies the Project No. of the production order.';
    //         }
    //         field("Site"; Rec."Site")
    //         {
    //             ApplicationArea = Manufacturing;
    //             Importance = Promoted;
    //             ToolTip = 'Specifies the Site No. of the production order.';
    //         }
    //         field("Shelter Id"; Rec."Shelter Id")
    //         {
    //             ApplicationArea = Manufacturing;
    //             Importance = Promoted;
    //             ToolTip = 'Specifies the Shelter Id of the production order.';
    //         }
    //         field("Shelter Name"; Rec."Shelter Name")
    //         {
    //             ApplicationArea = Manufacturing;
    //             Importance = Promoted;
    //             ToolTip = 'Specifies the Shelter Name of the production order.';
    //         }
    //         field("RSS No."; Rec."RSS No.")
    //         {
    //             ApplicationArea = Manufacturing;
    //             Importance = Promoted;
    //             ToolTip = 'Specifies the RSS No. of the production order.';
    //         }
    //     }
    // }

    // trigger OnAfterGetRecord()
    // begin
    //     StyleTxt := rec.GetStyleText();
    // end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     StyleTxt := Rec.GetStyleText();
    // end;

    // trigger OnDeleteRecord(): Boolean
    // begin
    //     StyleTxt := Rec.GetStyleText();
    // end;

    // trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    // begin
    //     StyleTxt := Rec.GetStyleText();
    // end;

    // var
    //     StyleTxt: Text;
}