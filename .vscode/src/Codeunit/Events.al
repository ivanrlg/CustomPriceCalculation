codeunit 70100 MyEvents
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Line - Price", 'OnAfterAddSources', '', false, false)]
    local procedure OnAfterAddSources(
    SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line";
    PriceType: Enum "Price Type"; var PriceSourceList: Codeunit "Price Source List");
    var
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        if not GeneralLedgerSetup."Use Sell-to in Sales Prices" then
            exit;

        Customer.Get(SalesHeader."Sell-to Customer No.");

        PriceSourceList.Init();
        PriceSourceList.Add("Price Source Type"::"All Customers");
        PriceSourceList.Add("Price Source Type"::Customer, SalesHeader."Sell-to Customer No.");
        PriceSourceList.Add("Price Source Type"::Contact, SalesHeader."Sell-to Contact No.");
        PriceSourceList.Add("Price Source Type"::Campaign, SalesHeader."Campaign No.");
        AddActivatedCampaignsAsSource(PriceSourceList);
        PriceSourceList.Add("Price Source Type"::"Customer Price Group", Customer."Customer Price Group");
        PriceSourceList.Add("Price Source Type"::"Customer Disc. Group", Customer."Customer Disc. Group");
    end;

    procedure AddActivatedCampaignsAsSource(var PriceSourceList: Codeunit "Price Source List")
    var
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
        SourceType: Enum "Price Source Type";
    begin
        if FindActivatedCampaign(TempTargetCampaignGr, PriceSourceList) then
            repeat
                PriceSourceList.Add(SourceType::Campaign, TempTargetCampaignGr."Campaign No.");
            until TempTargetCampaignGr.Next() = 0;
    end;

    local procedure FindActivatedCampaign(var TempCampaignTargetGr: Record "Campaign Target Group" temporary; var PriceSourceList: Codeunit "Price Source List"): Boolean
    var
        PriceSourceType: enum "Price Source Type";
    begin
        TempCampaignTargetGr.Reset();
        TempCampaignTargetGr.DeleteAll();

        if PriceSourceList.GetValue(PriceSourceType::Campaign) = '' then
            if not FindCustomerCampaigns(PriceSourceList.GetValue(PriceSourceType::Customer), TempCampaignTargetGr) then
                FindContactCompanyCampaigns(PriceSourceList.GetValue(PriceSourceType::Contact), TempCampaignTargetGr);

        exit(TempCampaignTargetGr.FindFirst());
    end;

    local procedure FindCustomerCampaigns(CustomerNo: Code[20]; var TempCampaignTargetGr: Record "Campaign Target Group" temporary) Found: Boolean;
    var
        CampaignTargetGr: Record "Campaign Target Group";
    begin
        CampaignTargetGr.SetRange(Type, CampaignTargetGr.Type::Customer);
        CampaignTargetGr.SetRange("No.", CustomerNo);
        Found := CampaignTargetGr.CopyTo(TempCampaignTargetGr);
    end;

    local procedure FindContactCompanyCampaigns(ContactNo: Code[20]; var TempCampaignTargetGr: Record "Campaign Target Group" temporary) Found: Boolean
    var
        CampaignTargetGr: Record "Campaign Target Group";
        Contact: Record Contact;
    begin
        if Contact.Get(ContactNo) then begin
            CampaignTargetGr.SetRange(Type, CampaignTargetGr.Type::Contact);
            CampaignTargetGr.SetRange("No.", Contact."Company No.");
            Found := CampaignTargetGr.CopyTo(TempCampaignTargetGr);
        end;
    end;

}