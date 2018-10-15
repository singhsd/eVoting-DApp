pragma solidity ^0.4.0;
/*
use asserts for over or underflow checks
use events, if necessary
Questions:
1. can unregistered voters see results?
2. can registered candidates vote?
3. what to do if votes are tied?
4. should show number of votes of all candidates, or just show winner?
*/
contract Voting {
    /// candidate structure
    /// votes have the total number of votes candidate secured
    struct Candidate {
        string name;
        // uint votes;
    }
        
    /// array of candidates
    Candidate[] candidates;
    /// mapping of voter to has_voted
    mapping(address => uint) voter;
    /// mapping of candidate to number_of_votes
    mapping(string => uint) votes;
    /// number of candidates
    uint num_candidates;
    
    /// time and phase constants
    uint starting_phase;
    uint candidate_registration_phase;
    uint voter_registration_phase;
    uint voting_phase;
    uint result_declaration_phase;
    
    constructor () public {
        starting_phase = now;
        num_candidates = 0;
        candidate_registration_phase = 2 * 60; // 5 minutes * 60 seconds per minute
        voter_registration_phase = 2 * 60; // 5 minutes * 60 seconds per minute
        voting_phase = 2 * 60; // 5 minutes * 60 seconds per minute
        result_declaration_phase = 2 * 60; // 5 minutes * 60 seconds per minute
        
        /*
        INITIALIZATION INSTRUCTIONS:
        ->  every candidate registered will have initial votes = 1
            so that unregistered candidates will have initial votes = 0,
            easy to differentiate
            This is applicable to all candidates, and since all have same starting
            point, the relative count of votes is unchanged
        
        ->  every registered voter will have vote = 1
            so that unregistered candidates will have vote = 0,
            and after voting, vote = 2,
            easy to differentiate
        */
    }
    
    // modifiers
    
    modifier candidate_registration() {
        require(
            now < starting_phase + candidate_registration_phase,
            "Candidate registration phase ended"
            );
        _;
    }
    
    modifier voter_registration() {
        require(
            now > starting_phase + candidate_registration_phase,
            "Voter registration phase yet to come"
            );
        require(
            now < starting_phase + candidate_registration_phase + voter_registration_phase,
            "Voter resistration ended"
            );
        _;
    }
    
    modifier voting_period() {
        require(
            now > starting_phase + candidate_registration_phase + voter_registration_phase,
            "Voting phase yet to come"
            );
        require(
            now < starting_phase + candidate_registration_phase + voter_registration_phase + voting_phase,
            "Voting period ended"
            );
        _;
    }
    
    modifier result_declaration() {
        require(
            now > starting_phase + candidate_registration_phase + voter_registration_phase + voting_phase,
            "Result declaration phase yet to come"
            );
        _;
    }
    
    // Getter functions
    
    function get_candidate_number() 
        public 
        constant 
        returns (uint) {
        return num_candidates;
    }
    
    function get_candidate_info(uint id) 
        public 
        constant 
        returns (string) {
        // can be modified later to give out more details
        return candidates[id].name;
    }
    
    // State Changing Functions
    
    function register_candidate(string name) 
        public 
        candidate_registration()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        // check if already exists, should change to require?
        if(votes[name] > 0) {
            status = 0;
        }
        else {
            Candidate memory newCandidate = Candidate(name); // ...name,0);
            candidates.push(newCandidate);
            votes[name] = 1;
            num_candidates++;
            status = 1;
        }
    }
    
    function register_voter() 
        public 
        voter_registration()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        // check if already exists, should change to require?
        if(voter[msg.sender] > 0) {
            status = 0;
        }
        else {
            voter[msg.sender] = 1;
            status = 1;
        }
    }
    
    function vote(string candidate_name) 
        public 
        voting_period()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        if(votes[candidate_name] < 1 || voter[msg.sender] != 1)
        {
            status = 0;
        }
        else {
            voter[msg.sender] = 2;
            votes[candidate_name]++;
            status = 1;
        }
    }
    
    function get_results() 
        public 
        constant 
        result_declaration()
        returns (string) {
       uint max_votes = 0;
       string memory winner = "None";
       uint n = candidates.length;
       for( uint i=0; i<n; i++)
       {
           if(max_votes < votes[candidates[i].name])
           {
               max_votes = votes[candidates[i].name];
               winner = candidates[i].name;
           }
           else if (max_votes == votes[candidates[i].name])
           {
               winner = "No definite winner";
           }
       }
       return winner;
    }
}