codeunit 50001 "Cmtl Prod Evt. Subscriber Mgt"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Report, Report::"Replan Production Order", 'OnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify', '', false, false)]
    local procedure OnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify(var ProdOrder: Record "Production Order"; MainProdOrder: Record "Production Order"; ProdOrderComp: Record "Prod. Order Component")
    var
    begin
    end;

    var
        myInt: Integer;
}