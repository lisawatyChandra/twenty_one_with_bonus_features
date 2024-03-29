SUITS = %w(♥ ♦ ♣ ♠)
VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A)

def greetings
  puts '************************************************************'
  puts ''
  puts 'Welcome to Twenty-One'.center(60)
  puts ''
  puts '************************************************************'
  sleep 2
  puts ''
  puts 'First player to win five rounds wins the game.'.center(60)
  sleep 3
end

def initialize_deck!
  SUITS.product(VALUES).shuffle
end

def deal_initial_cards!(deck, player_cards, dealer_cards)
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end
end

def display_initial_hands(player_cards, dealer_cards)
  puts "player has: #{player_cards[0].join}, #{player_cards[1].join}"
  puts "dealer has: #{dealer_cards[0].join} and ?"
end

def total(cards)
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    if value == 'A'
      sum += 11
    elsif value.to_i == 0
      sum += 10
    else
      sum += value.to_i
    end
  end

  # correct for Aces
  values.select { |value| value == 'A' }.count.times do
    sum -= 10 if sum > 21
  end

  sum
end

def string_of_hand(cards)
  cards.map(&:join).join(', ')
end

def player_sequence(deck, player_cards, player_total)
  puts 'Player turn...'
  player_turn = nil
  loop do
    puts 'Would you like to (h)it or (s)tay?'
    player_turn = gets.chomp.downcase
    break if ['h', 's'].include?(player_turn)
    puts "Sorry, must enter 'h' or 's'"
  end

  if player_turn == 'h'
    puts 'You chose to hit!'
    player_cards << deck.pop
    player_total = total(player_cards)
    puts "player cards are now: #{string_of_hand(player_cards)}"
  end

  [player_turn, player_total]
end

def dealer_sequence(deck, dealer_cards, dealer_total)
  loop do
    break if dealer_total >= 17
    puts 'Dealer turn...'
    puts 'Dealer hits!'
    dealer_cards << deck.pop
    dealer_total = total(dealer_cards)
    puts "Dealer cards are now: #{string_of_hand(dealer_cards)}"
    sleep 2
  end

  dealer_total
end

def busted?(total)
  total > 21
end

def detect_round_winner(player_total, dealer_total)
  if player_total > 21
    :player_busted
  elsif dealer_total > 21
    :dealer_busted
  elsif player_total > dealer_total
    :player
  elsif player_total < dealer_total
    :dealer
  else
    :tie
  end
end

def declare_round_winner(player_total, dealer_total)
  result = detect_round_winner(player_total, dealer_total)

  case result
  when :player_busted
    puts 'Player busted! Dealer wins this round!'
  when :dealer_busted
    puts 'Dealer busted! Player wins this round!'
  when :player
    puts 'Player wins this round!'
  when :dealer
    puts 'Dealer wins this round!'
  else
    puts "It's a tie on this round!"
  end
end

def play_again?
  puts '************************************************************'
  puts ''
  puts 'Would you like to play again? (y or n)'.center(60)
  puts ''
  puts '************************************************************'
  answer = gets.chomp
  sleep 0.25
  answer.downcase.start_with?('y')
end

def display_both_hands(player_cards, dealer_cards, player_total, dealer_total)
  puts ''
  puts "Dealer has: #{string_of_hand(dealer_cards)} "
    .concat("for a total of #{dealer_total}")
  puts ''
  puts "Player has: #{string_of_hand(player_cards)} "
    .concat("for a total of #{player_total}")
  puts ''
end

def update_score_board!(round_winner, round_state)
  case round_winner
  when :player        then round_state[:player] += 1
  when :dealer_busted then round_state[:player] += 1
  when :dealer        then round_state[:dealer] += 1
  when :player_busted then round_state[:dealer] += 1
  when :tie           then round_state[:ties] += 1
  end
end

def display_scoreboard(round_state)
  puts ''
  puts '************************************************************'
  puts ''
  puts ("Round #{round_state[:rounds]} scores: " \
    "PLAYER - #{round_state[:player]}, " \
    "DEALER - #{round_state[:dealer]}, " \
    "TIES - #{round_state[:ties]}").center(60)
  puts ''
  puts '************************************************************'
end

def display_end_of_round_results(player_cards, dealer_cards, player_total,
                                 dealer_total, round_state)
  display_both_hands(player_cards, dealer_cards, player_total, dealer_total)
  declare_round_winner(player_total, dealer_total)
  display_scoreboard(round_state)
end

def declare_grand_winner(round_state)
  puts ''
  if round_state[:dealer] >= 5
    puts "After #{round_state[:rounds]} rounds, Dealer has won five times!"
      .center(60)
  elsif round_state[:player] >= 5
    puts "After #{round_state[:rounds]} rounds, Player has won five times!"
      .center(60)
  end
  puts ''
end

def grandwinner?(round_state)
  round_state[:player] >= 5 || round_state[:dealer] >= 5
end

def reset!(round_state)
  round_state[:rounds] = 1
  round_state[:player] = 0
  round_state[:dealer] = 0
  round_state[:ties] = 0
end

def increment_rounds!(round_state)
  round_state[:rounds] += 1
end

def enter_to_continue
  puts 'Press Enter to continue: '
  gets
end

def tournament_over?(round_state)
  is_over = grandwinner?(round_state)
  if is_over
    declare_grand_winner(round_state)
    reset!(round_state)
  end
  
  is_over
end

round_state = { rounds: 1, player: 0, dealer: 0, ties: 0 }
round_winner = nil

greetings

# main loop
loop do # round loop
  system 'clear'
  deck = initialize_deck!
  player_cards = []
  dealer_cards = []

  deal_initial_cards!(deck, player_cards, dealer_cards)

  player_total = total(player_cards)
  dealer_total = total(dealer_cards)

  display_initial_hands(player_cards, dealer_cards)

  # player turn
  puts ''
  loop do
    player_turn, player_total = player_sequence(deck, player_cards, player_total)
    break if player_turn == 's' || busted?(player_total)
  end

  if busted?(player_total) # when player_total > 21
    round_winner = detect_round_winner(player_total, dealer_total)
    update_score_board!(round_winner, round_state)

    display_end_of_round_results(player_cards, dealer_cards, player_total,
                                 dealer_total, round_state)

    if tournament_over?(round_state)
      play_again? ? next : break
    else
      increment_rounds!(round_state)
      enter_to_continue
      next
    end

  else # when player_total <= 21
    puts "You chose to stay at #{player_total}"
  end

  # dealer turn
  puts ''
  dealer_total = dealer_sequence(deck, dealer_cards, dealer_total)

  if busted?(dealer_total) # when dealer_total > 21
    round_winner = detect_round_winner(player_total, dealer_total)
    update_score_board!(round_winner, round_state)

    display_end_of_round_results(player_cards, dealer_cards, player_total,
                                 dealer_total, round_state)

    if tournament_over?(round_state)
      play_again? ? next : break
    else
      increment_rounds!(round_state)
      enter_to_continue
      next
    end
  else # when dealer_total >= 17 && dealer_total <= 21
    puts "Dealer stays at #{dealer_total}"
  end

  # both player and dealer stay; compare cards
  round_winner = detect_round_winner(player_total, dealer_total)
  update_score_board!(round_winner, round_state)

  display_end_of_round_results(player_cards, dealer_cards, player_total,
                               dealer_total, round_state)

  if tournament_over?(round_state)
    break unless play_again?
  else
    increment_rounds!(round_state)
    enter_to_continue
  end
end

puts ''
puts 'Thank you for playing Twenty-One. Goodbye!'
