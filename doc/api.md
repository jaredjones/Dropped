Overview
--------

- Two types of users on our sever
    - Facebook accouts (referenced by Facebook userID)
    - Anonymous accounts (referenced by a deviceID that we generate server-side upon request)

- Each "Facebook account" that we store will map some number of deviceIDs to the Facebook userID (each Facebook account can have multiple "installs")
    - I would have a separate FacebookAccounts and Devices tables, with a userID column in the Devices table

- Each deviceID will have an associated "alias" that is displayed instead of their real name. When logging
  into Facebook, we'll need to merge the aliases associated with each device somehow.

- When a user first opens the app, we'll generate a device id for them and they will be an anonymous user

- As soon as they log in to Facebook:
    - Check to see if that Facebook userID is in the database
    - If we don't have it already, create it and associate the deviceID
    - If we have it already, associate the deviceID

- When a user logs out of Facebook, disassociate the deviceID. If there are no deviceIDs associated with the Facebook userID after loggin
  out, concede any matches that Facebook userID is participating in.

- Message bodies should be JSON for ease of both human and computer parsing (for now, we're just in testing. We can encrypt later).

Methods
-------

- deviceID and userID are passed to all methods. They will be an empty string if not specified

- Generate new device identifier (only if there hasn't been one generated yet)
    - POST opcode 0
    - Request:
        - { "pass" : "..." }
    - Response:
        - { "deviceID" : "..." }

    - Stored on the client after generation
    - The client is forbidden from knowing any device identifiers other than its own

- Validate deviceID/pass pair
    - POST opcode 1
    - Request:
        - { "deviceID" : "...",
            "pass"     : "..." }
    - Response:
        - { "isValidPair" : "..." }

- Get Alias
    - POST opcode 2
    - Request:
        - { "deviceID" : "..." (possibly empty, but only if there is no userID),
            "userID"   : "..." (empty if not set yet) }
    - Response:
        - { "alias" : "..." }

    - Gets the alias for the deviceID or Facebook userID
    - If userID is specified, ignore deviceID

- Set Alias
    - POST opcode 3
    - Request:
        { "deviceID" : "...",
          "userID"   : "...",
          "pass"     : "...",
          "alias"    : "..." }
    - Response:
        - { "alias" : "..." }

    - The new Alias MUST BE Alphanumerical Only!!!!
    - If userID is specified, set the alias for all associated deviceIDs

- MatchIDs
    - POST opcode 11
    - Request:
        - { "deviceID" : "...",
            "userID"   : "..." }
    - Response:
        - { "matchIDs" : [id1, id2, ...] }

    - As usual, use userID if it's specified and deviceID otherwise
    - Returns array of strings (JSON, aren't you awesome)

- Request match
    - POST opcode 12
    - Request:
        - { "deviceID" : "...",
            "userID"   : "...",
            "pass"     : "...",
            "friendID" : "..." (empty for anonymous) }
    - Response:
        - { "matchID" : "..." }

    - Returns a matchID for a new match. Will fill any half-full matches before starting new ones.

    - If userID is specified, associate the match with the userID
    - Else, associate the match with the deviceID

    - Optionally takes a friend's Facebook userID and force a new match (unless there's a half-full match
      with that friend's userID)

- Match Data
    - POST opcode 13
    - Request:
        - { "deviceID" : "...",
            "userID"   : "..." }
    - Response:
        - { "matchData"         : "...",
            "localPlayerTurn"   : "...",
            "remotePlayerAlias" : "...",
            "matchStatus"       : "..." }

    - localPlayerTurn is either 0 or 1 (first or second turn)

- Submit Turn
    - POST opcode 14
    - Request:
        - { "deviceID"      : "...",
            "userID"        : "...",
            "pass"          : "...",
            "advanceTurn"   : "0 or 1"
            "matchID"       : "...",
            "matchData"     : "..." }
    - Response
        - { "matchStatus" : "..." }

    - Pass in new matchData
    - Make sure to keep track of how many moves have been made in a game and don't accept turn submissions past that
    - Don't advance the turn unless advanceTurn == 1. That way initial matchData can be saved when the first player's
      client generates the match
    - Advances the game and possibly ends it (visible in the matchStatus passed back)

- Concede Match
    - POST opcode 15
    - Request:
         - { "deviceID" : "..." }

    - Mark the match as finished

- Facebook Associate
    - POST opcode 21
    - Request:
        { "deviceID" : "...",
           "userID"  : "...",
           "pass"    : "..." }

    - Facebook User Docs: https://developers.facebook.com/docs/graph-api/reference/user
    - Links device identifier to the Facebook userID
    - This is called after the user successfully logs in on the client

- Facebook Disassociate
    - POST opcode 22
    - Request:
        { "deviceID" : "...",
           "userID"  : "...",
           "pass"    : "..." }

    - Disassociate the deviceID (convert to anonymous account)

- Facebook friends
    - POST opcode 23
    - Request:
        - { "deviceID" : "...",
            "userID"   : "..." }
    - Response:
        - { "friendIDs" : [userID1, userID2, ... ] }

    - Returns all of the user's Facebook friends that have already installed and signed in to Dropped
    - Verify that deviceID and userID are associated

