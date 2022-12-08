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
    }
}