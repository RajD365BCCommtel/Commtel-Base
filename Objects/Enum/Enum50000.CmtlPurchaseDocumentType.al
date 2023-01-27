#pragma warning disable AA0215
enum 50000 "Cmtl Purchase Document Type"
#pragma warning restore AA0215
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "Requisition") { Caption = 'Requisition'; }
    value(1; "Quote") { Caption = 'Quote'; }
    value(2; "Blanket Order") { Caption = 'Blanket Order'; }
    value(3; "Order") { Caption = 'Order'; }
    value(4; "Invoice") { Caption = 'Invoice'; }
    value(5; "Return Order") { Caption = 'Return Order'; }
    value(6; "Credit Memo") { Caption = 'Credit Memo'; }
    value(7; "Posted Receipt") { Caption = 'Posted Receipt'; }
    value(8; "Posted Invoice") { Caption = 'Posted Invoice'; }
    value(9; "Posted Return Shipment") { Caption = 'Posted Return Shipment'; }
    value(10; "Posted Credit Memo") { Caption = 'Posted Credit Memo'; }
    value(11; "Arch. Requisition") { Caption = 'Arch. Requisition'; }
    value(12; "Arch. Quote") { Caption = 'Arch. Quote'; }
    value(13; "Arch. Order") { Caption = 'Arch. Order'; }
    value(14; "Arch. Blanket Order") { Caption = 'Arch. Blanket Order'; }
    value(15; "Arch. Return Order") { Caption = 'Arch. Return Order'; }
}