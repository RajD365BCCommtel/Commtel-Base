codeunit 50000 "Cmtl Prod. Ordr Mgt"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempProdOrder: Record "Production Order" temporary;

    procedure UpdatePresentationOrder()
    var
        ProdOrder: Record "Production Order";
    begin
        TempProdOrder.Reset();
        TempProdOrder.DeleteAll();

        // This is to cleanup wrong created blank entries created by an import mistake
        if TempProdOrder.Get(TempProdOrder.Status::Released, '') then
            TempProdOrder.Delete();

        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        if ProdOrder.FindSet(false, false) then
            repeat
                TempProdOrder.TransferFields(ProdOrder);
                TempProdOrder.Insert();
            until ProdOrder.Next() = 0;
        UpdatePresentationOrderIterative();
    end;

    local procedure UpdatePresentationOrderIterative()
    var
        ProdOrder: Record "Production Order";
        TempStack: Record TempStack temporary;
        TempCurProdOrder: Record "Production Order" temporary;
        CurProdOrderID: RecordID;
        PresentationOrder: Integer;
        Indentation: Integer;
        HasChildren: Boolean;
    begin
        PresentationOrder := 0;

        TempCurProdOrder.Copy(TempProdOrder, true);

        TempProdOrder.SetCurrentKey("Parent Prod Order No.");
        TempProdOrder.Ascending(false);
        TempProdOrder.SetRange(Status, TempProdOrder.Status::Released);
        TempProdOrder.SetRange("Parent Prod Order No.", '');
        if TempProdOrder.FindSet(false, false) then
            repeat
                TempStack.Push(TempProdOrder.RecordId());
            until TempProdOrder.Next() = 0;

        while TempStack.Pop(CurProdOrderID) do begin
            TempCurProdOrder.Get(CurProdOrderID);
            HasChildren := false;

            TempProdOrder.SetRange(Status, TempProdOrder.Status::Released);
            TempProdOrder.SetRange("Parent Prod Order No.", TempCurProdOrder."No.");
            if TempProdOrder.FindSet(false, false) then
                repeat
                    TempStack.Push(TempProdOrder.RecordId());
                    HasChildren := true;
                until TempProdOrder.Next() = 0;

            if TempCurProdOrder."Parent Prod Order No." <> '' then begin
                TempProdOrder.Get(TempCurProdOrder."Parent Prod Order No.");
                Indentation := TempProdOrder.Indentation + 1;
            end else
                Indentation := 0;
            PresentationOrder := PresentationOrder + 10000;

            if (TempCurProdOrder."Presentation Order" <> PresentationOrder) or
               (TempCurProdOrder.Indentation <> Indentation) or (TempCurProdOrder."Has Children" <> HasChildren)
            then begin
                ProdOrder.Get(TempCurProdOrder."No.");
                ProdOrder.Validate("Presentation Order", PresentationOrder);
                ProdOrder.Validate(Indentation, Indentation);
                ProdOrder.Validate("Has Children", HasChildren);
                ProdOrder.Modify();
                TempProdOrder.Get(TempCurProdOrder."No.");
                TempProdOrder.Validate("Presentation Order", PresentationOrder);
                TempProdOrder.Validate(Indentation, Indentation);
                TempProdOrder.Validate("Has Children", HasChildren);
                TempProdOrder.Modify();
            end;
        end;
    end;

    procedure DoesValueExistInItemCategories(Text: Code[20]; var ProdOrder: Record "Item Category"): Boolean
    begin
        ProdOrder.Reset();
        ProdOrder.SetFilter(Code, '@' + Text);
        exit(ProdOrder.FindSet());
    end;

    procedure CalcPresentationOrder(var ProdOrder: Record "Production Order")
    var
        ProdOrderSearch: Record "Production Order";
        ProdOrderPrev: Record "Production Order";
        ProdOrderNext: Record "Production Order";
        ProdOrderPrevExists: Boolean;
        ProdOrderNextExists: Boolean;
    begin
        with ProdOrder do begin
            if HasChildren() then begin
                "Presentation Order" := 0;
                exit;
            end;

            ProdOrderPrev.SetRange(Status, ProdOrderPrev.Status::Released);
            ProdOrderPrev.SetRange("Parent Prod Order No.", "Parent Prod Order No.");
            ProdOrderPrev.SetFilter("No.", '<%1', "No.");
            ProdOrderPrevExists := ProdOrderPrev.FindLast();
            if not ProdOrderPrevExists then
                ProdOrderPrevExists := ProdOrderPrev.Get(ProdOrderPrev.Status::Released, "Parent Prod Order No.")
            else
                ProdOrderPrev.Get(ProdOrderPrev.Status::Released, GetLastChildCode(ProdOrderPrev."No."));

            ProdOrderNext.SetRange(Status, ProdOrderNext.Status::Released);
            ProdOrderNext.SetRange("Parent Prod Order No.", "Parent Prod Order No.");
            ProdOrderNext.SetFilter("No.", '>%1', "No.");
            ProdOrderNextExists := ProdOrderNext.FindFirst();
            if not ProdOrderNextExists and ProdOrderPrevExists then begin
                ProdOrderNext.Reset();
                ProdOrderNext.SetCurrentKey("Presentation Order");
                ProdOrderNext.SetRange(Status, ProdOrderNext.Status::Released);
                ProdOrderNext.SetFilter("No.", '<>%1', "No.");
                ProdOrderNext.SetFilter("Presentation Order", '>%1', ProdOrderPrev."Presentation Order");
                ProdOrderNextExists := ProdOrderNext.FindFirst();
            end;

            case true of
                not ProdOrderPrevExists and not ProdOrderNextExists:
                    "Presentation Order" := 10000;
                not ProdOrderPrevExists and ProdOrderNextExists:
                    "Presentation Order" := ProdOrderNext."Presentation Order" div 2;
                ProdOrderPrevExists and not ProdOrderNextExists:
                    "Presentation Order" := ProdOrderPrev."Presentation Order" + 10000;
                ProdOrderPrevExists and ProdOrderNextExists:
                    "Presentation Order" := (ProdOrderPrev."Presentation Order" + ProdOrderNext."Presentation Order") div 2;
            end;

            ProdOrderSearch.SetRange(Status, ProdOrderSearch.Status::Released);
            ProdOrderSearch.SetRange("Presentation Order", "Presentation Order");
            ProdOrderSearch.SetFilter("No.", '<>%1', "No.");
            if not ProdOrderSearch.IsEmpty() then
                "Presentation Order" := 0;
        end;
    end;

    procedure CheckPresentationOrder()
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.SetRange("Presentation Order", 0);
        if not ProdOrder.IsEmpty() then
            UpdatePresentationOrder();
    end;

    local procedure GetLastChildCode(ParentCode: Code[20]) ChildCode: Code[20]
    var
        TempStack: Record TempStack temporary;
        ProdOrder: Record "Production Order";
        RecId: RecordID;
    begin
        ChildCode := ParentCode;

        ProdOrder.Ascending(false);
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange("Parent Prod Order No.", ParentCode);
        if ProdOrder.FindSet() then
            repeat
                TempStack.Push(ProdOrder.RecordId());
            until ProdOrder.Next() = 0;

        while TempStack.Pop(RecId) do begin
            ProdOrder.Get(RecId);
            ChildCode := ProdOrder."No.";

            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Parent Prod Order No.", ProdOrder."No.");
            if ProdOrder.FindSet() then
                repeat
                    TempStack.Push(ProdOrder.RecordId());
                until ProdOrder.Next() = 0;
        end;
    end;
}

