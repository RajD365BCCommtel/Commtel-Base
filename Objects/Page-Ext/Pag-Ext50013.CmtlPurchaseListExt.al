#pragma warning disable AA0215
pageextension 50013 "CmtlPurchaseListExt" extends "Purchase List"
#pragma warning restore AA0215
{
    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Is Requisition", false);
        Rec.FilterGroup(0);
    end;
}