#pragma warning disable AA0215
pageextension 50018 "CmtlPurchStatistics" extends "Purchase Statistics"
#pragma warning restore AA0215
{
    trigger OnAfterGetRecord()
    begin
        if Rec."Is Requisition" then
            CurrPage.Caption(StrSubstNo(CText001, 'Requisition'));
    end;

    var
        CText001: Label 'Purchase %1 Statistics';
}