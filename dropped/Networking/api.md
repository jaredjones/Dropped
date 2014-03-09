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

- Generate new device identifier (only if there hasn't been one generated yet)
    - GET /device/generate-device-id
    - Response body:
        - { deviceID : "..." }

    - Stored on the client after generation
    - The client is forbidden from knowing any device identifiers other than its own
    - Every POST requires a deviceID to be passed in so only requests originiating from
      a device will work

    - This method is a potential for spamming. What should we do about that?

- Get Alias
    - GET /device/deviceID/alias
    - GET /user/userID/alias
    - Response body:
        - { alias : "..." }

    - Gets the alias for the deviceID or Facebook userID
    - The second method returns the most recently set alias

- Set Alias
    - POST /device/deviceID/alias
    - POST /user/userID/alias
    - Request body:
        { alias : "..." }
    - The new Alias MUST BE Alphanumerical Only!!!!

    - Sets the alias for the deviceID
    - The second method sets the alias of all associated deviceIDs

- Facebook Log In
    - POST /facebook-login
    - Request body:
        { deviceID : "...", userID : "..." }

    - Facebook User Docs: https://developers.facebook.com/docs/graph-api/reference/user
    - Links device identifier to the Facebook userID
    - This is called _after_ the user successfully logs in on the client

- Facebook Log Out
    - POST /facebook-logout
    - Request body:
        { deviceID : "...", userID : "..." }

    - Disassociate the deviceID (convert to anonymous account)

- Facebook friends
    - GET /user/userID/facebook-friends
    - Response body:
        - { friendIDs : [ id1, id2, ... ] }

    - Returns all of the user's Facebook friends that have already installed and signed in to Dropped

- Request match
    - POST /new-match
    - Request body:
        - { deviceID : "...", userID : "...", friendID : "..." (empty for anonymous) }
    - Response body:
        - { matchID : "..." }

    - Returns a matchID for a new match. Will fill any half-full matches before starting new ones.
    - Optionally takes a friend's Facebook userID and force a new match (unless there's a half-full match
      with that friend's userID)

- Match Data
    - GET /match/matchID/match-data
    - Response body:
        - { matchData : "...", isLocalPlayerTurn : "...", remotePlayerAlias : "..." }

- Submit Turn
    - POST /match/matchID/submit
    - Request body:
        - { deviceID : "...", matchData : "..." }

    - Pass in new matchData
    - Make sure to keep track of how many moves have been made in a game and don't accept turn submissions past that
    - Advances the game and possibly ends it

- Concede Match
    - POST /match/matchID/concede
    - Request body:
         - { deviceID : "..." }

    - Mark the match as finished

