tableextension 70100 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(70100; "Use Sell-to in Sales Prices"; Boolean)
        {
            Caption = 'Use Sell-to in Sales Prices';
            DataClassification = ToBeClassified;
        }
    }
}

