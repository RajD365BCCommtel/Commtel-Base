#pragma warning disable AA0215
page 50000 "Cmtl Run Object"
#pragma warning restore AA0215
{
    ApplicationArea = All;
    Caption = 'Run Object';
    PageType = List;
    SourceTable = AllObj;
    UsageCategory = Tasks;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    SourceTableView = WHERE("Object Type" = FILTER(Table | Page | Report | Codeunit | XMLport));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the object.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the object.';
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the object.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Run Object")
            {
                Caption = 'Run Object';
                Promoted = true;
                PromotedIsBig = true;
                ToolTip = 'Run any objects with Business Central';
                Image = Process;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    _ObjString: Text;
                begin
                    CASE Rec."Object Type" OF
                        rec."Object Type"::Page:
                            PAGE.RUN(Rec."Object ID");
                        rec."Object Type"::Report:
                            REPORT.RUN(Rec."Object ID");
                        rec."Object Type"::Codeunit:
                            CODEUNIT.RUN(Rec."Object ID");
                        rec."Object Type"::XMLport:
                            XMLPORT.RUN(Rec."Object ID");
                        rec."Object Type"::Table:
                            BEGIN
                                _ObjString := GETURL(CLIENTTYPE::Current, COMPANYNAME, OBJECTTYPE::Table, Rec."Object ID");
                                HYPERLINK(_ObjString)
                            END;
                    END;
                END;
            }
        }
    }
}
