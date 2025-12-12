module voting::simple_vote;

use sui::table::{Self, Table};

use std::string::String;

// ==================== Errors ====================
const EAlreadyVoted: u64 = 1;
const ENotVoted: u64 = 2;

// ==================== One-Time Witness ====================
public struct SIMPLE_VOTE has drop {}

// ==================== Capability ====================
public struct AdminCap has key {
    id: UID
}

// ==================== Core Struct ====================
public struct Poll has key {
    id: UID,
    question: String,
    option_a: String,
    option_b: String,
    votes: Table<address, u8> // 1 = option A, 2 = option B
}

// ==================== Functions ====================

/// Initialize - create AdminCap
fun init(_otw: SIMPLE_VOTE, ctx: &mut TxContext) {
    transfer::transfer(
        AdminCap { id: object::new(ctx) },
        ctx.sender()
    );
}

/// 1. Create poll (admin only)
public entry fun create_poll(
        _admin: &AdminCap,
        question: String,
        option_a: String,
        option_b: String,
        ctx: &mut TxContext
) {
    let poll = Poll {
        id: object::new(ctx),
        question,
        option_a,
        option_b,
        votes: table::new(ctx)
    };
    transfer::share_object(poll);
}

/// 2. Delete poll (admin only)
public entry fun delete_poll(
        _admin: &AdminCap,
        poll: Poll
) {
        let Poll { id, question: _, option_a: _, option_b: _, votes } = poll;
        table::drop(votes);
        object::delete(id);
    }

    /// 3. New vote (option: 1 for A, 2 for B)
    public entry fun new_vote(poll: &mut Poll, option: u8, ctx: &mut TxContext) {
        let voter = ctx.sender();
        assert!(!table::contains(&poll.votes, voter), EAlreadyVoted);
        table::add(&mut poll.votes, voter, option);
    }

    /// 4. Update vote
    public entry fun update_vote(poll: &mut Poll, new_option: u8, ctx: &mut TxContext) {
        let voter = ctx.sender();
        assert!(table::contains(&poll.votes, voter), ENotVoted);
        let vote = table::borrow_mut(&mut poll.votes, voter);
        *vote = new_option;
    }

    /// 5. Delete vote
    public entry fun delete_vote(poll: &mut Poll, ctx: &mut TxContext) {
        let voter = ctx.sender();
        assert!(table::contains(&poll.votes, voter), ENotVoted);
        table::remove(&mut poll.votes, voter);
    }

    /// 6. Get vote
    public entry fun get_vote(poll: &Poll, voter: address): u8 {
        *table::borrow(&poll.votes, voter)
    }
