tableextension 50000 "CmtlProdOrderExt" extends "Production Order"
{
    fields
    {
        field(50000; "Project No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Site"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Shelter Id"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Shelter Name"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "RSS No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50005; "Parent Prod Order No."; Code[20])
        {
            Caption = 'Parent Prod Order No';
            TableRelation = "Production Order"."No.";

            trigger OnValidate()
            var
                ProductionOrder: Record "Production Order";
                ParentProdOrderNo: Code[20];
            begin
                ParentProdOrderNo := Rec."Parent Prod Order No.";
                while ProductionOrder.Get(ProductionOrder.Status::Released, ParentProdOrderNo) do begin
                    if ProductionOrder."No." = Rec."No." then
                        Error(CyclicInheritanceErr);
                    ParentProdOrderNo := ProductionOrder."Parent Prod Order No.";
                end;
                //if "Parent Prod Order No." <> xRec."Parent Prod Order No." then
                //ItemAttributeManagement.UpdateCategoryAttributesAfterChangingParentCategory(Code, "Parent Prod Order No.", xRec."Parent Prod Order No.");
            end;
        }
        field(50006; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
        }
        field(50007; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
        }
        field(50008; "Has Children"; Boolean)
        {
            Caption = 'Has Children';
        }
    }

    keys
    {
        key(Key1; "Parent Prod Order No.")
        {
        }
        key(Key2; "Presentation Order")
        {
        }
    }

    trigger OnDelete()
    begin
        if HasChildren() then
            Error(DeleteWithChildrenErr);
        UpdateDeletedProdOrderno();
    end;

    trigger OnInsert()
    begin
        TestField(Rec."No.");
        UpdateIndentation();
        ProdOrdrMgt.CalcPresentationOrder(Rec);
    end;

    trigger OnModify()
    begin
        UpdateIndentation();
        ProdOrdrMgt.CalcPresentationOrder(Rec);
    end;

    trigger OnRename()
    begin
        "Presentation Order" := 0;
    end;

    procedure HasChildren(): Boolean
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange("Parent Prod Order No.", Rec."No.");
        exit(not ProdOrder.IsEmpty)
    end;

    procedure GetStyleText(): Text
    begin
        if Indentation = 0 then
            exit('Strong');

        if HasChildren() then
            exit('Attention');

        exit('');
    end;

    local procedure UpdateDeletedProdOrderno()
    var
        ProductionOrder: Record "Production Order";
        DeleteInheritedProOrderno: Boolean;
    begin
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        ProductionOrder.SetRange("No.", Rec."No.");
        if ProductionOrder.IsEmpty() then
            exit;
        DeleteInheritedProOrderno := Confirm(StrSubstNo(DeleteInheritedProdOrderNoQst, Rec."No."));
        if ProductionOrder.Find('-') then
            repeat
            // ProductionOrder.Validate("Item Category Code", '');
            // ProductionOrder.Modify();
            // if DeleteInheritedProOrderno then
            //     ItemAttributeManagement.DeleteItemAttributeValueMapping(CategoryItem, TempCategoryItemAttributeValue);
            until ProductionOrder.Next() = 0;
    end;

    local procedure UpdateIndentation()
    var
        ParentProdOrder: Record "Production Order";
    begin
        if ParentProdOrder.Get(Rec.Status::Released, Rec."Parent Prod Order No.") then
            UpdateIndentationTree(ParentProdOrder.Indentation + 1)
        else
            UpdateIndentationTree(0);
    end;

    procedure UpdateIndentationTree(Level: Integer)
    var
        ProdOrder: Record "Production Order";
    begin
        Indentation := Level;

        ProdOrder.SetRange(Status, Rec.Status::Released);
        ProdOrder.SetRange("Parent Prod Order No.", Rec."No.");
        if ProdOrder.FindSet() then
            repeat
                ProdOrder.UpdateIndentationTree(Level + 1);
                ProdOrder.Modify();
            until ProdOrder.Next() = 0;
    end;


    var
        ProdOrdrMgt: Codeunit "Cmtl Prod. Ordr Mgt";
        CyclicInheritanceErr: Label 'An Production Order cannot be a parent of itself or any of its children.';
        DeleteWithChildrenErr: Label 'You cannot delete this Production Order because it has child Production Order.';
        DeleteInheritedProdOrderNoQst: Label 'One or more Prod Order no belong to Production Orders ''''%1''''.\\Do you want to delete the inherited Production Orders for the Prod Order No in question? ', Comment = '%1 - Prod Order No.';
}