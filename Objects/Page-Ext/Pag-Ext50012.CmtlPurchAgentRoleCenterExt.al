#pragma warning disable AA0215
pageextension 50012 "CmtlPurchAgentRoleCenterExt" extends "Purchasing Agent Role Center"
#pragma warning restore AA0215
{
    actions
    {
        addbefore(PurchaseOrders)
        {
            action(PurchaseRequisition)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Requisition';
                RunObject = Page "Cmtl Purchase Requisitions";
                ToolTip = 'Create purchase requisitions to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase orders dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase orders allow partial receipts, unlike with purchase invoices, and enable drop shipment directly from your vendor to your customer. Purchase requisitions can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
            }
        }

        addbefore("Purchase &Quote")
        {
            action("Purchase &Requisition")
            {
                ApplicationArea = Suite;
                Caption = 'Purchase &Requisition';
                Image = Quote;
                //Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Cmtl Purchase Requisition";
                RunPageMode = Create;
                ToolTip = 'Create a new purchase requisition, for example to reflect a request for requisition.';
            }
        }
    }
}