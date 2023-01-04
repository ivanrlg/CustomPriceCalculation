pageextension 70100 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    layout
    {
        addafter("VAT in Use")
        {
            field(NewPostedSalesNumber; Rec."Use Sell-to in Sales Prices")
            {
                ApplicationArea = All;
                Caption = 'Use Sell-to in Sales Prices';
            }
        }
    }
}