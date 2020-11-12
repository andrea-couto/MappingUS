struct StateInfo
{
    let statAbbreviation: String
    let stateName: String
    var selected: Bool = false
}

struct Constants
{
    static var stateDictionary: [StateInfo] =
    [
        StateInfo(statAbbreviation: "AK", stateName: "Alaska"),
        StateInfo(statAbbreviation: "AL", stateName: "Alabama"),
        StateInfo(statAbbreviation: "AZ", stateName: "Arkansas"),
        StateInfo(statAbbreviation: "AK", stateName: "Arizona"),
        StateInfo(statAbbreviation: "CA", stateName: "California"),
        StateInfo(statAbbreviation: "CO", stateName: "Colorado"),
        StateInfo(statAbbreviation: "CT", stateName: "Connecticut"),
        StateInfo(statAbbreviation: "DE", stateName: "Delaware"),
        StateInfo(statAbbreviation: "FL", stateName: "Florida"),
        StateInfo(statAbbreviation: "GA", stateName: "Georgia"),
        StateInfo(statAbbreviation: "HI", stateName: "Hawaii"),
        StateInfo(statAbbreviation: "IA", stateName: "Iowa"),
        StateInfo(statAbbreviation: "ID", stateName: "Idaho"),
        StateInfo(statAbbreviation: "IL", stateName: "Illinois"),
        StateInfo(statAbbreviation: "IN", stateName: "Indiana"),
        StateInfo(statAbbreviation: "KS", stateName: "Kansas"),
        StateInfo(statAbbreviation: "KY", stateName: "Kentucky"),
        StateInfo(statAbbreviation: "LA", stateName: "Louisiana"),
        StateInfo(statAbbreviation: "MA", stateName: "Massachusetts"),
        StateInfo(statAbbreviation: "MD", stateName: "Maryland"),
        StateInfo(statAbbreviation: "ME", stateName: "Maine"),
        StateInfo(statAbbreviation: "MI", stateName: "Michigan"),
        StateInfo(statAbbreviation: "MN", stateName: "Minnesota"),
        StateInfo(statAbbreviation: "MO", stateName: "Missouri"),
        StateInfo(statAbbreviation: "MS", stateName: "Mississippi"),
        StateInfo(statAbbreviation: "MT", stateName: "Montana"),
        StateInfo(statAbbreviation: "NC", stateName: "North Carolina"),
        StateInfo(statAbbreviation: "ND", stateName: "North Dakota"),
        StateInfo(statAbbreviation: "NE", stateName: "Nebraska"),
        StateInfo(statAbbreviation: "NH", stateName: "New Hampshire"),
        StateInfo(statAbbreviation: "NJ", stateName: "New Jersey"),
        StateInfo(statAbbreviation: "NM", stateName: "New Mexico"),
        StateInfo(statAbbreviation: "NV", stateName: "Nevada"),
        StateInfo(statAbbreviation: "NY", stateName: "New York"),
        StateInfo(statAbbreviation: "OH", stateName: "Ohio"),
        StateInfo(statAbbreviation: "OK", stateName: "Oklahoma"),
        StateInfo(statAbbreviation: "OR", stateName: "Oregon"),
        StateInfo(statAbbreviation: "PA", stateName: "Pennsylvania"),
        StateInfo(statAbbreviation: "RI", stateName: "Rhode Island"),
        StateInfo(statAbbreviation: "SC", stateName: "South Carolina"),
        StateInfo(statAbbreviation: "SD", stateName: "South Dakota"),
        StateInfo(statAbbreviation: "TN", stateName: "Tennessee"),
        StateInfo(statAbbreviation: "TX", stateName: "Texas"),
        StateInfo(statAbbreviation: "UT", stateName: "Utah"),
        StateInfo(statAbbreviation: "VA", stateName: "Virginia"),
        StateInfo(statAbbreviation: "VT", stateName: "Vermont"),
        StateInfo(statAbbreviation: "WA", stateName: "Washington"),
        StateInfo(statAbbreviation: "WI", stateName: "Wisconsin"),
        StateInfo(statAbbreviation: "WV", stateName: "West Virginia"),
        StateInfo(statAbbreviation: "WY", stateName: "Wyoming")
    ]
}
