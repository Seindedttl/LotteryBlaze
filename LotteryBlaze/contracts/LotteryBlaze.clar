;; Decentralized Lottery and Raffle Smart Contract
;; A secure, transparent lottery system supporting multiple concurrent lotteries with configurable entry fees,
;; automatic winner selection using verifiable randomness, prize distribution with fee collection,
;; and comprehensive lottery management including emergency controls and participant tracking.

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-LOTTERY-NOT-FOUND (err u101))
(define-constant ERR-LOTTERY-CLOSED (err u102))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u103))
(define-constant ERR-ALREADY-ENTERED (err u104))
(define-constant ERR-NO-PARTICIPANTS (err u105))
(define-constant ERR-LOTTERY-ACTIVE (err u106))
(define-constant ERR-INVALID-PARAMETERS (err u107))
(define-constant MIN-ENTRY-FEE u1000000) ;; 1 STX minimum
(define-constant MAX-PARTICIPANTS u1000)
(define-constant HOUSE-FEE-PERCENTAGE u5) ;; 5% house fee
(define-constant MIN-DURATION u144) ;; ~24 hours in blocks

;; data maps and vars
(define-data-var next-lottery-id uint u1)
(define-data-var total-collected-fees uint u0)
(define-data-var emergency-pause bool false)

(define-map lotteries
  uint
  {
    name: (string-ascii 50),
    entry-fee: uint,
    prize-pool: uint,
    start-block: uint,
    end-block: uint,
    max-participants: uint,
    current-participants: uint,
    status: (string-ascii 20), ;; ACTIVE, CLOSED, DRAWN
    winner: (optional principal),
    created-by: principal
  })

(define-map participants
  {lottery-id: uint, participant: principal}
  {entry-block: uint, ticket-number: uint})

(define-map lottery-participants
  {lottery-id: uint, ticket-number: uint}
  principal)

(define-map user-lottery-count
  principal
  uint)

;; private functions
(define-private (calculate-house-fee (amount uint))
  (/ (* amount HOUSE-FEE-PERCENTAGE) u100))

(define-private (generate-random-winner (lottery-id uint) (participant-count uint))
  (let ((block-time (unwrap-panic (get-block-info? time (- block-height u1))))
        (block-height-seed block-height))
    (let ((random-seed (+ block-time block-height-seed lottery-id (* block-height u7) (* lottery-id u13))))
      (mod random-seed participant-count))))

(define-private (is-lottery-active (lottery-id uint))
  (match (map-get? lotteries lottery-id)
    lottery (and (<= (get start-block lottery) block-height)
                 (> (get end-block lottery) block-height)
                 (is-eq (get status lottery) "ACTIVE"))
    false))

(define-private (update-user-stats (user principal))
  (let ((current-count (default-to u0 (map-get? user-lottery-count user))))
    (map-set user-lottery-count user (+ current-count u1))))

;; public functions
(define-public (create-lottery
  (name (string-ascii 50))
  (entry-fee uint)
  (duration-blocks uint)
  (max-participants uint))
  (let ((lottery-id (var-get next-lottery-id)))
    (asserts! (not (var-get emergency-pause)) ERR-UNAUTHORIZED)
    (asserts! (>= entry-fee MIN-ENTRY-FEE) ERR-INVALID-PARAMETERS)
    (asserts! (>= duration-blocks MIN-DURATION) ERR-INVALID-PARAMETERS)
    (asserts! (<= max-participants MAX-PARTICIPANTS) ERR-INVALID-PARAMETERS)
    
    (map-set lotteries lottery-id {
      name: name,
      entry-fee: entry-fee,
      prize-pool: u0,
      start-block: block-height,
      end-block: (+ block-height duration-blocks),
      max-participants: max-participants,
      current-participants: u0,
      status: "ACTIVE",
      winner: none,
      created-by: tx-sender
    })
    
    (var-set next-lottery-id (+ lottery-id u1))
    (ok lottery-id)))

(define-public (enter-lottery (lottery-id uint))
  (let ((lottery (unwrap! (map-get? lotteries lottery-id) ERR-LOTTERY-NOT-FOUND))
        (entry-fee (get entry-fee lottery))
        (current-participants (get current-participants lottery)))
    
    (asserts! (not (var-get emergency-pause)) ERR-UNAUTHORIZED)
    (asserts! (is-lottery-active lottery-id) ERR-LOTTERY-CLOSED)
    (asserts! (< current-participants (get max-participants lottery)) ERR-LOTTERY-CLOSED)
    (asserts! (is-none (map-get? participants {lottery-id: lottery-id, participant: tx-sender})) ERR-ALREADY-ENTERED)
    
    ;; Transfer entry fee
    (try! (stx-transfer? entry-fee tx-sender (as-contract tx-sender)))
    
    ;; Add participant
    (map-set participants {lottery-id: lottery-id, participant: tx-sender} 
             {entry-block: block-height, ticket-number: current-participants})
    (map-set lottery-participants {lottery-id: lottery-id, ticket-number: current-participants} tx-sender)
    
    ;; Update lottery stats
    (map-set lotteries lottery-id 
             (merge lottery {
               current-participants: (+ current-participants u1),
               prize-pool: (+ (get prize-pool lottery) entry-fee)
             }))
    
    (update-user-stats tx-sender)
    (ok true)))

(define-public (draw-winner (lottery-id uint))
  (let ((lottery (unwrap! (map-get? lotteries lottery-id) ERR-LOTTERY-NOT-FOUND)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (>= block-height (get end-block lottery)) ERR-LOTTERY-ACTIVE)
    (asserts! (is-eq (get status lottery) "ACTIVE") ERR-LOTTERY-CLOSED)
    (asserts! (> (get current-participants lottery) u0) ERR-NO-PARTICIPANTS)
    
    (let ((winner-ticket (generate-random-winner lottery-id (get current-participants lottery)))
          (winner-address (unwrap-panic (map-get? lottery-participants {lottery-id: lottery-id, ticket-number: winner-ticket})))
          (prize-pool (get prize-pool lottery))
          (house-fee (calculate-house-fee prize-pool))
          (winner-prize (- prize-pool house-fee)))
      
      ;; Update lottery status
      (map-set lotteries lottery-id 
               (merge lottery {status: "DRAWN", winner: (some winner-address)}))
      
      ;; Transfer prize to winner
      (try! (as-contract (stx-transfer? winner-prize tx-sender winner-address)))
      
      ;; Collect house fee
      (var-set total-collected-fees (+ (var-get total-collected-fees) house-fee))
      
      (print {event: "lottery-drawn", lottery-id: lottery-id, winner: winner-address, prize: winner-prize})
      (ok winner-address))))

(define-public (emergency-pause-toggle)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set emergency-pause (not (var-get emergency-pause)))
    (ok (var-get emergency-pause))))

(define-public (withdraw-house-fees)
  (let ((fees (var-get total-collected-fees)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (> fees u0) ERR-INVALID-PARAMETERS)
    
    (try! (as-contract (stx-transfer? fees tx-sender CONTRACT-OWNER)))
    (var-set total-collected-fees u0)
    (ok fees)))


