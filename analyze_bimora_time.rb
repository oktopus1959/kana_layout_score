#! /usr/bin/env ruby

$debug = true
$milestoneDebug = false
$timeTableDump = false
$strokeTableDump = false

TimeTableFile = 'oooka/oooka_time_table.txt'

MoraFile = 'kouy/kouy_2mora.txt'
#MoraFile = 'oka/mixed_hiragana.2mora.txt'
#MoraFile = 'oooka/fusinotani.2mora.txt'

# 左手に対する時間補正
$doLeftHandAdjust = ENV['ADJUST_TIME_TABLE'] == 'false' ? false : true
LEFTHAND_FIRST_ADJUST_FACTOR = 0.93
LEFTHAND_SECOND_ADJUST_FACTOR = 0.85

# 数字段に対するペナルティ
PENALTY_TOPMOST = [5.0, 1.0, 1.0, 2.5, 3.5, 3.5, 2.5, 1.0, 1.0, 3.5]

# 右小指外側に対するペナルティ (-, ^, |, @, [, :, ], \)
PENALTY_OUTRIGHT = [1.5, 2.0, 2.5, 0.5, 1.0, 0.5, 1.0, 0.5, 1.0]

# スペースキーに対するペナルティ
SPACE_PENALTY = 1.0

# 各種シフトキーのオフセット
SANDS_OFFSET = 200
SUCC_COMBO_OFFSET = 500 # 連続シフト
ONESHOT_OFFSET = 800    # ワンショット
FPLR_OFFSET = 900       # 先押し後離し

# ペナルティコストの既定値
$decomboShiftCost = 1.0   # 同時打鍵から単打への移行コスト
$preventComboCost = 2.0   # 単打２連接が同時打鍵と重複している場合に、単打2連接として判定させるためのコスト
$comboShiftCost = 2.0     # 第2モーラが２キー同時打鍵の場合のコスト
$sandsComboCost = 3.0     # 第2モーラがSandS同時打鍵の場合のコスト
$sandsDecomboCost = 3.0   # SandS同時打鍵から単打への移行コスト
$fprtComboCost = 4.0      # 第2モーラが先押し後離し打鍵の場合のコスト
$tripleComboCost = 5.0    # 第2モーラが２キー同時打鍵の場合のコスト

# ペナルティコストの計算に平均連接運指コストに対する係数を使う
$useCostRate = true
DECOMBO_SHIFT_COST_RATE = 0.2
PREVENT_COMBO_COST_RATE = 0.4
COMBO_SHIFT_COST_RATE = 0.4
SANDS_COMBO_COST_RATE = 0.4
SANDS_DECOMBO_COST_RATE = 0.4
FPLR_COMBO_COST_RATE = 1.0
TRIPLE_COMBO_COST_RATE = 0.5

$multiStroke = false
# ロールオーバー可の場合の加速係数
KSK_FACTOR = ENV['KSK_FACTOR'] ? ENV['KSK_FACTOR'].to_f : 1.0
#KSK_FACTOR = 0.7
STDERR.puts "KSK_FACTOR=#{KSK_FACTOR.round(2)}"

def isSingle(strk)
  strk < 100
end

def isSandS(strk)
  strk >= SANDS_OFFSET && strk < SUCC_COMBO_OFFSET
end

def isSuccessiveCombo(strk)
  strk >= SUCC_COMBO_OFFSET && strk < ONESHOT_OFFSET
end

def isOneshotCombo(strk)
  strk >= ONESHOT_OFFSET && strk < FPLR_OFFSET
end

def isFplrCombo(strk)
  strk >= FPLR_OFFSET
end

$time_table = []

def _lefthand_adjust(list, bLeft)
  if $doLeftHandAdjust
    for i in 0...30
      if i % 10 < 5
        list[i] *= LEFTHAND_SECOND_ADJUST_FACTOR
      end
      list[i] *= LEFTHAND_FIRST_ADJUST_FACTOR if bLeft
    end
  end
  list
end

#-------------------------------------------------------------------
# 30x30 連接運指時間表の読み込み
#-------------------------------------------------------------------
time_table_31x31 = []
lineIdx = 0
File.readlines(TimeTableFile).each do |line|
  time_table_31x31.push(_lefthand_adjust(line.strip.split(/\t/).map{|x| x.to_f}, lineIdx % 10 < 5))
  lineIdx += 1
end

#time_table_31x31.each {|items|
#  STDERR.puts items.map{|x| x.round(2).to_s}.join("\t")
#}

if $useCostRate
  meanFingeringCost = time_table_31x31.map{|list| list.sum}.sum / time_table_31x31.map{|list| list.size}.sum
  $decomboShiftCost = meanFingeringCost * DECOMBO_SHIFT_COST_RATE
  $preventComboCost = meanFingeringCost * PREVENT_COMBO_COST_RATE
  $comboShiftCost = meanFingeringCost * COMBO_SHIFT_COST_RATE
  $sandsComboCost = meanFingeringCost * SANDS_COMBO_COST_RATE
  $sandsDecomboCost = meanFingeringCost * SANDS_DECOMBO_COST_RATE
  $fprtComboCost = meanFingeringCost * FPLR_COMBO_COST_RATE
  $tripleComboCost = meanFingeringCost * TRIPLE_COMBO_COST_RATE

  if $debug && !$timeTableDump
    STDERR.puts "meanFingeringCost=#{meanFingeringCost.round(2)}"
    STDERR.puts "decomboShiftCost=#{$decomboShiftCost.round(2)}"
    STDERR.puts "preventComboCost=#{$preventComboCost.round(2)}"
    STDERR.puts "comboShiftCost=#{$comboShiftCost.round(2)}"
    STDERR.puts "sandsComboCost=#{$sandsComboCost.round(2)}"
    STDERR.puts "sandsDecomboCost=#{$sandsDecomboCost.round(2)}"
    STDERR.puts "fprtComboCost=#{$fprtComboCost.round(2)}"
    STDERR.puts "tripleComboCost=#{$tripleComboCost.round(2)}"
  end
end

# Spaceキーに対応する部分を外挿
for i in 0...30
  list = time_table_31x31[i]
  list.push(list[20..29].min + SPACE_PENALTY)   # Time(X→>SP) = min(Time(X->y)) for y in [下段キー]
end
# Time(Space->X) = min(Time(y->X)) for y in [下段キー]
sp_list = []
for i in 0...30
  sp_list[i] = [time_table_31x31[20][i], time_table_31x31[21][i], time_table_31x31[22][i], time_table_31x31[23][i], time_table_31x31[24][i], 
                time_table_31x31[25][i], time_table_31x31[26][i], time_table_31x31[27][i], time_table_31x31[28][i], time_table_31x31[29][i]].min + SPACE_PENALTY
end
# Space->Space = min(Time(x->x)) for any x
sp_sp = 100.0
for i in 0...30
  if sp_sp > time_table_31x31[i][i]
    sp_sp = time_table_31x31[i][i]
  end
end
sp_list.push(sp_sp + SPACE_PENALTY)
time_table_31x31.push(sp_list)

# 右小指外側に対する外挿
def extraporate_outright(list)
  list.push(list[9] + PENALTY_OUTRIGHT[0])  # for '-'
  list.push(list[9] + PENALTY_OUTRIGHT[1])  # for '^'
  list.push(list[9] + PENALTY_OUTRIGHT[2])  # for '|'
  list.push(list[9] + PENALTY_OUTRIGHT[3])  # for '@'
  list.push(list[9] + PENALTY_OUTRIGHT[4])  # for '['
  list.push(list[19] + PENALTY_OUTRIGHT[5])  # for ':'
  list.push(list[19] + PENALTY_OUTRIGHT[6])  # for ']'
  list.push(list[29] + PENALTY_OUTRIGHT[7])  # for '\'
  list.push(list[29] + PENALTY_OUTRIGHT[8])  # for dummy(49)
end

# 数字段の外挿
for i in 0...10
  list = time_table_31x31[i].dup  # 上段キーから外挿する
  extraporate_outright(list)  # 右小指外側に対する外挿
  list = list[0...10] + list   # 数字段に対する外挿; 数字段同士の値は、数字段から上段への値と同じと仮定
  $time_table[i] = list.map{|v| v + PENALTY_TOPMOST[i]}   # 数字段からのペナルティ加算
end

# 上段、中段、下段に対する外挿
for i in 0..30
  list = time_table_31x31[i].dup
  extraporate_outright(list)  # 右小指外側に対するペナルティ計算
  list = list[0...10] + list   # 数字段に対する外挿; 数字段同士の値は、数字段から上段への値と同じと仮定
  for j in 0...10
    list[j] += PENALTY_TOPMOST[j]   # 数字段に対するペナルティ加算
  end
  $time_table[10+i] = list
end

# 右小指外側に対する外挿
for i in 0...9
  list = time_table_31x31[i < 5 ? 9 : i < 7 ? 19 : 29].dup  # 'p' for -,^,|,@,[, ';' for :, ], '/' for \
  extraporate_outright(list)  # 右小指外側に対するペナルティ計算
  list = list[0...10] + list   # 数字段に対する外挿; 数字段同士の値は、数字段から上段への値と同じと仮定
  list = list.map{|v| v + PENALTY_OUTRIGHT[i]}  # 右小指外側からのペナルティ可算
  for j in 0...10
    list[j] += PENALTY_TOPMOST[j]   # 数字段に対するペナルティ加算
  end
  $time_table[41+i] = list
end

if $timeTableDump
  QWERTY = " 1234567890QWERTYUIOPASDFGHJKL；ZXCVBNM，．／空－＾￥＠［：］＼ "
  STDERR.puts QWERTY.split('').join("\t")
  i = 0
  $time_table.each {|items|
    STDERR.puts QWERTY[i+1] + "\t" + items.map{|x| x.round(2).to_s}.join("\t")
    i += 1
  }
  exit(0)
end

$stroke_list_map = {}
$combo_map = {}       # 連続する単打が同時打鍵にもなるかどうか

def makeComboKey(list)
  fact = 1
  comboKey = 0
  list.each {|x|
    comboKey = comboKey * fact + (x % 100)
    fact *= 100
  }
  comboKey
end

def _calcStrokeCost(list)
  cost = 0.0
  list.each {|x|
    x %= 100
    for i in 10...40
      cost += $time_table[x][i] + $time_table[i][x]
    end
  }
  cost
end

#-------------------------------------------------------------------
# 配列のストローク表の読み込み
#-------------------------------------------------------------------
while line = gets
  if line =~ /# *multistroke/i
    $multiStroke = true
    STDERR.puts "\n---- multiStroke ----" if $debug && !$strokeTableDump
    next
  end
  items = line.strip.split(/\t/)
  word = items.delete_at(0)
  list = items.map{|x| x.to_i}
  next unless word && word.length > 0 && list && list.size > 0
  if isSandS(list[0])
    # SandS
    list[0] %= 100
    list.insert(0, 240) # Spaceを挿入
  end

  if $stroke_list_map[word]
    $stroke_list_map[word].push(list)
  else
    $stroke_list_map[word] = [list]
  end

  if list[0] < FPLR_OFFSET
    # タイミング自由の同時打鍵の場合
    $combo_map[makeComboKey(list)] = true
    if list.size == 2
      # 逆順
      $combo_map[makeComboKey([list[1], list[0]])] = true
    end
  end

  STDERR.puts "#{word}: #{list.join(',')}" if $strokeTableDump
end

# ゲタ文字はホームポジションの位置とする
$stroke_list_map["〓"] = [[20], [21], [22], [23], [26], [27], [28], [29]]

#-------------------------------------------------------------------
# 以下、計算のメイン
total_count = 0
total_score = 0.0

MAX_CONNECTION_COST = 20.0
ERROR_COST = 10000.0

def _makeStrokeListStr(list)
  list.map{|x| x.to_s}.join(':')
end

def _makeStrokesListStr(list)
  list.map{|x| _makeStrokeListStr(x)}.join('/')
end

def _interStrokeCost(x, y)
  idx1 = x % 100
  idx2 = y % 100
  if idx1 < $time_table.size && idx2 < $time_table.size
    STDERR.puts "_interStrokeCost(#{x}, #{y})=#{$time_table[idx1][idx2].round(2)}" if $debug
    $time_table[idx1][idx2]
  else
    STDERR.puts "out of range: _interStrokeCost(#{x}, #{y})" if $debug
    ERROR_COST
  end
end

def _maxCost(x, y, cost)
  oldCost = cost
  resultCost = cost
  cost = _interStrokeCost(x, y)
  if resultCost < cost
    resultCost = cost
  end
  STDERR.puts "_maxCost: x=#{x}, y=#{y}, oldCost=#{oldCost.round(2)}: resultCost=#{resultCost.round(2)}" if $debug
  resultCost
end

# 2つの打鍵列間の最大コスト
def maxCost(combo1, combo2)
  cost = 0.0
  combo1.each {|x|
    combo2.each {|y|
      cost = _maxCost(x, y, cost)
    }
  }
  STDERR.puts "maxCost: #{_makeStrokeListStr(combo1)}, #{_makeStrokeListStr(combo2)}, : cost=#{cost.round(2)}" if $debug
  cost
end

def _shiftCost(head1, combo2)
  if combo2.size == 1 || isSingle(combo2[0])
    # ?打鍵⇒>1打鍵
    if head1 == '〓' || isSingle(head1) || isOneshotCombo(head1)
      # 前が、げた文字or多スクトークorワンショットならノーペナ
      STDERR.puts "_shiftCost: OneShot: 0.0" if $debug
      0.0
    elsif isSandS(head1)
      STDERR.puts "_shiftCost: SandS Decombo: #{$sandsDecomboCost.round(2)}" if $debug
      $sandsDecomboCost
    else
      STDERR.puts "_shiftCost: Decombo: #{$decomboShiftCost.round(2)}" if $debug
      $decomboShiftCost
    end
  elsif combo2.size > 2
    # ?打鍵⇒>3打鍵
    STDERR.puts "_shiftCost: Triple: #{$tripleComboCost.round(2)}" if $debug
    $tripleComboCost
  else #combo2.size == 2
    # ?打鍵⇒>2打鍵
    STDERR.puts "_shiftCost: #{isSandS(combo2[0]) ? "SandS" : "Double"}: #{isSandS(combo2[0]) ? $sandsComboCost.round(2) : $comboShiftCost.round(2)}" if $debug
    isSandS(combo2[0]) ? $sandsComboCost : $comboShiftCost
  end
end

def _xchgShift(combo)
  STDERR.puts "_xchgShift: ENTER: combo=#{_makeStrokeListStr(combo)}" if $debug
  x = combo[0]
  combo[0] = combo[1] % 100 + (x / 100) * 100
  combo[1] = x % 100
  STDERR.puts "_xchgShift: LEAVE: combo=#{_makeStrokeListStr(combo)}" if $debug
end

def _procSameShift(combo1, combo2)
  if combo1.size >= 2 && combo2.size >= 2 && combo1[0] / 100 == combo2[0] / 100
    s11 = combo1[0] % 100
    s12 = combo1[1] % 100
    s21 = combo2[0] % 100
    s22 = combo2[1] % 100
    if s11 == s22
      _xchgShift(combo2)
    elsif s12 == s21
      _xchgShift(combo1)
    elsif s12 == s22
      _xchgShift(combo2)
      _xchgShift(combo1)
    end
  end
end

def _getShiftKind(head)
  if isSandS(head)
    "SandS"
  elsif isSuccessiveCombo(head)
    "Successive"
  elsif isOneshotCombo(head)
    "OneShot"
  elsif isFplrCombo(head)
    "FPLR"
  else
    "Single"
  end
end

# どちらかが同時打鍵or多ストロークのときのコスト計算
def calcMultiStrokeCost(combo1, combo2)
  _procSameShift(combo1, combo2)
  STDERR.puts "calcMultiStrokeCost: ENTER: #{_makeStrokeListStr(combo1)} (#{_getShiftKind(combo1[0])}), #{_makeStrokeListStr(combo2)} (#{_getShiftKind(combo2[0])})" if $debug
  head1 = combo1[0]
  head2 = combo2[0]
  if isFplrCombo(head2)
    # 後が先押し後離しの場合
    STDERR.puts "calcMultiStrokeCost: second is FPLR" if $debug
    if isFplrCombo(head1)
      # 前も先押し後離しの場合
      if head1 == head2
        # 前も同じシフトキー
        if combo2.size > 2
          # 後が3打以上: [X, A, B] -> [X, C, D]: max(cost(A->C), cost(B, C)) + cost(C->D)
          cost = maxCost(combo1[-1..-1], combo2[1..-2]) + _interStrokeCost(combo2[-2], combo2[-1])
        else
          cost = maxCost(combo1[-1..-1], combo2[-1..-1])
        end
      else
        # 前が異なるシフトキーの先押し後離しの場合
        cost = maxCost(combo1[-1..-1], combo2[0..-2]) + _interStrokeCost(combo2[-2], combo2[-1])
      end
    else
      if head1 == head2 && !isOneshotCombo(head1)
        # 前も同じシフトキー
        if combo2.size > 2
          # 後が3打以上: [X, A, B] -> [X, C, D]: max(cost(A->C), cost(B, C)) + cost(C->D)
          cost = maxCost(combo1[1..-1], combo2[1..-2]) + _interStrokeCost(combo2[-2], combo2[-1])
        else
          cost = maxCost(combo1[1..-1], combo2[-1..-1])
        end
      else
        # 前が異なるシフトキーかワンショットの場合
        cost = maxCost(combo1, combo2[0..-2]) + _interStrokeCost(combo2[-2], combo2[-1])
      end
    end
  elsif isFplrCombo(head1)
    # 前が先押し後離しの場合
    if head1 == head2
      # 前も同じシフトキー
      cost = maxCost(combo1[-1..-1], combo2[1..-1])
    else
      # 前が異なるシフトキーの場合
      cost = maxCost(combo1[-1..-1], combo2[0..-1]) + _shiftCost(head1, combo2)
    end
  elsif isOneshotCombo(head1)
    # 前がワンショット
    STDERR.puts "calcMultiStrokeCost: first is OneShot" if $debug
    cost = maxCost(combo1, combo2) + _shiftCost(head1, combo2)
  else
    if head1 == head2 && !isSingle(head1) && (combo1.size >= 2 && combo2.size >= 2)
      # どちらも2打鍵以上で同じシフトキーが続くケース
      STDERR.puts "calcMultiStrokeCost: Same Shift and both.size >= 2" if $debug
      cost = maxCost(combo1[1..-1], combo2[1..-1])
      if combo2.size > 2
        # 後が3打鍵のケースなら tripleComboCostを加算
        STDERR.puts "calcMultiStrokeCost: second.size >= 3" if $debug
        cost += _shiftCost(head1, combo2)
      end
    elsif isSingle(head2)
      # 後が多ストロークの場合
      STDERR.puts "calcMultiStrokeCost: second is multi-stroke" if $debug
      if isSingle(head1)
        cost = _interStrokeCost(combo1[-1], head2) * KSK_FACTOR
      else
        cost = maxCost(combo1, combo2[0,1]) + _shiftCost(head1, combo2)
      end
      for i in 0...combo2.size-1
        cost += _interStrokeCost(combo2[i], combo2[i+1]) * KSK_FACTOR
      end
    elsif isSingle(head1)
      # 前が多ストロークの場合
      STDERR.puts "calcMultiStrokeCost: first is multi-stroke" if $debug
      cost = maxCost(combo1[-1,1], combo2) + _shiftCost(head1, combo2)
    else
      # どちらかが単打、またはシフトキーが異なるケース
      STDERR.puts "calcMultiStrokeCost: Either one is Single or Shift keys are different" if $debug
      cost = maxCost(combo1, combo2) + _shiftCost(head1, combo2)
    end
  end
  if isFplrCombo(head1)
    # 前が先押し後離しの場合
    STDERR.puts "calcMultiStrokeCost: first is FPLR" if $debug
    cost += $fprtComboCost
  end
  STDERR.puts "calcMultiStrokeCost: LEAVE: cost=#{cost.round(2)}" if $debug
  cost
end

def _isSameCombo(combo1, combo2)
  return false if combo1.size != combo2.size || isSingle(combo1[0]) || isSingle(combo2[0])
  i = 0
  combo1.each {|x|
    return false if x != combo2[i]
    i += 1
  }
  return true
end

def _handle_tsu(strokes1, strokes2)
    if strokes2[0] == 99
      # 後が「っ」なら、T にする (「った」「って」「っと」で 58%を占めるため
      strokes2[0] = 14  # T
    end
    if strokes1[0] == 99
      # 前が「っ」なら、後の先頭ストロークを重ねる
      strokes1[0] = strokes2[0]
    end
end

def calcCost(strokes1, strokes2)
  STDERR.puts "calcCost: ENTER: #{_makeStrokeListStr(strokes1)}, #{_makeStrokeListStr(strokes2)}" if $debug
  _handle_tsu(strokes1, strokes2)
  STDERR.puts "calcCost: _handle_tsu: #{_makeStrokeListStr(strokes1)}, #{_makeStrokeListStr(strokes2)}" if $debug
  cost = ERROR_COST
  if !$multiStroke && strokes1.size == 1 && strokes2.size == 1
    # 単打の連続
    head1 = strokes1[0] % 100
    head2 = strokes2[0] % 100
    if $time_table[head1]
      cost = $time_table[head1][head2]
      if $combo_map[makeComboKey([head1, head2])]
        # 連続する単打が同時打鍵の組み合わせでもある場合
        STDERR.puts "calcCost: add PREVENT_COMBO_COST: #{$preventComboCost.round(2)}; oldCost=#{cost.round(2)}, " if $debug
        cost += $preventComboCost
      end
    end
  elsif _isSameCombo(strokes1, strokes2)
    # 同じ組み合わせの同時打鍵なので末尾キー同士の連続打鍵扱いとする
    cost = $time_table[strokes1[-1]][strokes2[-1]]
    STDERR.puts "calcCost: Same Combo: cost=#{cost.round(2)}" if $debug
  else
    # どちらかが同時打鍵or多ストローク
    cost = calcMultiStrokeCost(strokes1, strokes2)
  end
  STDERR.puts "calcCost: LEAVE: cost=#{cost.round(2)}" if $debug
  cost
end

def calcListCost(strokesList1, strokesList2)
  STDERR.puts "calcListCost: ENTER" if $debug
  minCost = ERROR_COST
  strokesList1.each {|x|
    strokesList2.each {|y|
      cost = calcCost(x, y)
      if cost < minCost
        minCost = cost
        STDERR.puts "calcListCost: new minCost=#{minCost.round(2)}" if $debug
      end
    }
  }
  STDERR.puts "calcListCost: LEAVE: minCost=#{minCost.round(2)}" if $debug
  minCost
end

#-------------------------------------------------------------------
# 2モーラ表の読み込みとコスト計算
#-------------------------------------------------------------------
STDERR.puts "\n---- START Cost Calc: #{MoraFile} ----" if $debug || $milestoneDebug

$moraCount = 0
$nextMileStone = 1

def _checkDebugMileStone()
  $moraCount += 1
  if $milestoneDebug
    $debug = $moraCount == $nextMileStone
    if $debug
      if $nextMileStone < 100
        $nextMileStone *= 10
      elsif $nextMileStone < 500
        $nextMileStone = 500
      elsif $nextMileStone < 1000
        $nextMileStone = 1000
      else
        $nextMileStone += 500
      end
    end
  end
end

# 2モーラ表の読み込みとコスト計算
File.readlines(MoraFile).each do |line|
  _checkDebugMileStone()
  items = line.strip.split(/\t/)
  count = items[0].to_i
  total_count += count
  word = items[1]
  STDERR.puts "----\n#{$moraCount}: word=#{word}, count=#{count}, total_count=#{total_count}" if $debug
  if word.length > 2 && word[1] =~ /[ぁぃぅぇぉゃゅょゎ]/
    mora1 = word[0..1]
    mora2 = word[2..-1]
  else
    mora1 = word[0..0]
    mora2 = word[1..-1]
  end

  STDERR.puts "mora1=#{mora1}, mora2=#{mora2}" if $debug

  cost = ERROR_COST
  strokesList1 = $stroke_list_map[mora1] ? $stroke_list_map[mora1].map{|list| list.dup} : []
  strokesList2 = $stroke_list_map[mora2] ? $stroke_list_map[mora2].map{|list| list.dup} : []
  if strokesList1.size > 0 && strokesList2.size > 0
    # どちらのモーラも打鍵表にある
    cost = calcListCost(strokesList1, strokesList2)
    if cost >= ERROR_COST
      STDERR.puts "can't calc cost: #{mora1}, #{mora2}"
    end
  end
  if cost >= ERROR_COST
    STDERR.puts "calc for each grams: #{word}: #{count}" if $debug
    cost = 0.0
    strokesLists = []
    if strokesList1.size == 0
      strokesList1 = $stroke_list_map[mora1[-1]] ? $stroke_list_map[mora1[-1]].map{|list| list.dup} : []
    end
    if strokesList1.size == 0
      cost = MAX_CONNECTION_COST
      STDERR.puts "no stroke for #{mora1[-1]}"
    else
      strokesLists.push(strokesList1)
      if strokesList2.size > 0
        strokesLists.push(strokesList2)
      else
        for i in 0...mora2.size
          strokesList2 = $stroke_list_map[mora2[i]] ? $stroke_list_map[mora2[i]].map{|list| list.dup} : []
          if strokesList2.size == 0
            cost = MAX_CONNECTION_COST
            STDERR.puts "no stroke for #{mora2[i]}"
            break
          else
            strokesLists.push(strokesList2)
          end
        end
      end
    end
    if cost == 0.0
      for i in 0...strokesLists.length-1
        strokesList1 = strokesLists[i]
        strokesList2 = strokesLists[i+1]
        cost += calcListCost(strokesList1, strokesList2)
        if cost >= ERROR_COST
          cost = MAX_CONNECTION_COST
          break
        end
        STDERR.puts "cost = #{cost.round(2)}" if $debug
      end 
    end
  end
  score = cost * count
  total_score += score
  STDERR.puts "#{$moraCount}: cost=#{cost.round(2)}, score=#{score.round(2)}, total_score=#{total_score.round(2)}" if $debug
end

STDERR.puts "----\nscore = #{(total_score / total_count).round(2)}; total_score = #{total_score.round(2)}, total_count = #{total_count}" if $debug || $milestoneDebug
puts "score = #{(total_score / total_count).round(2)}; total_score = #{total_score.round(2)}, total_count = #{total_count}"
