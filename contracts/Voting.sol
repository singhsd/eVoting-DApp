pragma solidity ^0.4.0;

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
    mapping(string => uint) voter;
    /// mapping of candidate to number_of_votes
    mapping(string => uint) votes;
    
    /// time and phase constants
    uint phase;
    uint candidate_registration_phase;
    uint voter_registration_phase;
    uint voting_phase;
    uint result_declaration_phase;
    
    constructor () public {
        phase = now;
        // define other phase constants here as seconds from epoch time,
        // but relative
    }
    
    function register_candidate(string name) public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already exists
        Candidate memory newCandidate = Candidate(name); // ...name,0);
        candidates.push(newCandidate);
        votes[name] = 0;
        status = 1;
    }
    
    function register_voter(string name) public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already exists
        voter[name] = 0;
        status = 1;
    }
    
    function vote(string voter_name, string candidate_name) public returns (uint status) {
        // check phase and return 0 if out of phase
        // also check if already voted
        voter[voter_name] = 1;
        votes[candidate_name]++;
        status = 1;
    }
    
    function get_results() public returns (string winner) {
        // check phase and return winner = "out of phase" if out of phase
        uint max_votes = 0;
        
    }
}