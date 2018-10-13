pragma solidity ^0.4.0;
/*
use asserts for over or underflow checks
use modifiers for phase checks
check all conditions
use events, if necessary
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
        candidate_registration_phase = 5 * 60; // 5 minutes * 60 seconds per minute
        voter_registration_phase = 5 * 60; // 5 minutes * 60 seconds per minute
        voting_phase = 5 * 60; // 5 minutes * 60 seconds per minute
        result_declaration_phase = 5 * 60; // 5 minutes * 60 seconds per minute
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
    
    function register_candidate(string name) 
        public 
        candidate_registration()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        // check phase and return 0 if out of phase
        // also check if already exists
        Candidate memory newCandidate = Candidate(name); // ...name,0);
        candidates.push(newCandidate);
        votes[name] = 0;
        status = 1;
        num_candidates++;
    }
    
    function register_voter() 
        public 
        voter_registration()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        // check phase and return 0 if out of phase
        // also check if already exists
        voter[msg.sender] = 0;
        status = 1;
    }
    
    function vote(string candidate_name) 
        public 
        voting_period()
        returns (uint status) {
            /*
            0, if unsuccessful
            1, otherwise
            */
        // check phase and return 0 if out of phase
        // also check if already voted
        // also check for valid voter, valid candidate
        voter[msg.sender] = 1;
        votes[candidate_name]++;
        status = 1;
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