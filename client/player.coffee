SkillType = 
	attack: 'attack'
	defense: 'defense'

SkillTiming = 
	afterDamage:'afterDamage'
	onAttack:'onAttack'
	onDefense:'onDefense'
	
DamageType = 
	hit: 'hit'
	poison: 'poison'
	double: 'double'
	
getSpecificDate = (month,date)->
	d = new Date()
	d.setMonth(month-1)
	d.setDate(date)
	d


AttackMessageType = 
	miss: 
		name:'miss'
		template:'miss'
	poisonAttack:
		name:'poisonAttack'
		template:'poisonAttack'
	doubleAttack:
		name:'doubleAttack'
		template:'doubleAttack'
	hit:
		name:'hit'
		template:'hit'
	suckBlood:
		name:'suckBlood'
		template:'suckBlood'

class Constellation
	constructor:(@name,@description,@beginDate,@endDate)->
	skills:[]
	isConstellationDate:->
		@beginDate <= new Date() <= @endDate
	effect:(player)->				
		hp = player.getHp()
		attack = player.getAttack()
		player.set {'hp':Math.floor(hp*1.2), 'attack':Math.floor(attack*1.2)}
	
class Libra extends Constellation
	constructor:->
		super('天平座', '天平座', getSpecificDate(9,23), getSpecificDate(10,23))
		@skills.unshift new DoubleAttack()
	hp:6
	attack:0.3

class Taurus extends Constellation
	constructor:->
		super('金牛座','金牛座', getSpecificDate(4,20), getSpecificDate(5,20))
		@skills.unshift new SuckBloodAttack()
	hp:2
	attack:0.6

class Scorpio extends Constellation
	constructor:->
		super('天蝎座','天蝎座', getSpecificDate(10,24), getSpecificDate(11,25))
		@skills.unshift new PoisonAttack()
	hp:3
	attack:0.6

class Damage
	constructor:(@value,@type)->

class Status
	constructor:(@name,@description,@timing)->
	action:(player)->
	
class ConstellationDate extends Status
	constructor:(@player)->
		super '本星之月','本星之月',''
	effect:->
		hp = @player.getHp()
		attack = @player.getAttack()
		@player.set {'hp':Math.floor(hp*1.2), 'attack':Math.floor(attack*1.2)}

class Skill
	constructor: (@name,@description,@type,@timing)->
	action:(attackPlayer,defensePlayer,attackResult)->
	rate:1
	check:->Math.random()<=@rate
	
class AttackSkill extends Skill
	constructor: (@name,@description,@timing)->
		super(@name,@description, SkillType.attack,@timing)
		
class DefenseSkill extends Skill
	constructor: (@name,@description,@timing)->
		super(@name,@description, SkillType.defense,@timing)

class Hit extends AttackSkill
	constructor: ->
		super('Hit','Normal hit',SkillTiming.onAttack)
	action:(attackPlayer,defensePlayer,attackResult)->
		if @check()
			attackValue = attackPlayer.get('attack')
			attackResult.damages.push(new Damage(attackValue,'hit'))
			attackResult.infoList.push AttackMessageType.hit
			return true
		else false
	
class DoubleAttack extends AttackSkill
	constructor: ->
		super('Double','Double hit',SkillTiming.onAttack)
	action:(attackPlayer,defensePlayer,attackResult)->
		if @check()
			attackValue = attackPlayer.get('attack')
			attackResult.damages.push(new Damage(attackValue * 2,'double'))
			attackResult.infoList.push AttackMessageType.doubleAttack
			return true
		else false
	rate:0.2
	
		
class PoisonAttack extends AttackSkill
	constructor: ->
		super('Poison','Poison hit',SkillTiming.onAttack)
	action:(attackPlayer,defensePlayer,attackResult)->
		if @check()
			attackValue = attackPlayer.get('attack')
			attackResult.damages.push(new Damage(attackValue,'hit'))
			attackResult.damages.push(new Damage(Math.floor(attackValue/3),'poison'))
			attackResult.infoList.push AttackMessageType.poisonAttack
			return true
		else false
	rate:0.2

class SuckBloodAttack extends AttackSkill
	constructor:->
		super('SuckBlood','SuckBlood hit',SkillTiming.afterDamage)
	action:(attackPlayer,defensePlayer,attackResult)->
		if not attackResult.isMissed
			attackPlayer.addHp(Math.floor(attackResult.damages[0].value*0.2))
			attackResult.infoList.push AttackMessageType.suckBlood
		false
	
class Dodge extends DefenseSkill
	constructor:->
		super('Dodge','Dodge attack',SkillTiming.onDefense)
	rate:0.2
	action:(attackPlayer,defensePlayer,attackResult)->
		if @check()
			attack.isMissed = true
			attack.infoList.push AttackMessageType.miss
			return true
		else false

class AttackResult
	constructor:(@infoList)->
		@infoList or= []
		@isMissed = false
		@damages = []
		@isDead = false
class Attack extends Backbone.Model
	constructor:(@attackPlayer,@defensePlayer)->
		@attackResult = new AttackResult()
	onAttack:->
		iterator = (skill)=>skill.action(@attackPlayer,@defensePlayer,@attackResult)
		_.any(@attackPlayer.getSkillsByType(SkillType.attack,SkillTiming.onAttack),iterator)
	onDefense:->
		iterator = (skill)=>skill.action(@attackPlayer,@defensePlayer,@attackResult)
		_.any(@attackPlayer.getSkillsByType(SkillType.defense,SkillTiming.onDefense),iterator)
	afterDamage:->
		iterator = (skill)=>skill.action(@attackPlayer,@defensePlayer,@attackResult)
		_.any(@attackPlayer.getSkillsByType(SkillType.attack,SkillTiming.afterDamage),iterator)
		_.any(@defensePlayer.getSkillsByType(SkillType.defense,SkillTiming.afterDamage),iterator)
	outputInfo:->
#		console.log(@attackPlayer.name+@attackPlayer.getHp() + '--'+ info.name+ '--'+ @defensePlayer.name+@defensePlayer.getHp()) for info in @attackResult.infoList
	damage:->
		if not @attackResult.isMissed
			for damage in @attackResult.damages
				@defensePlayer.set({'hp':@defensePlayer.get('hp') - damage.value})
				@attackResult.infoList.push {'name':'damage:'+damage.value,template:''}
		@attackResult.isDead = @defensePlayer.isDead()
	attack:->
		@onAttack()
		@onDefense()
		@damage()
		@afterDamage()
		@outputInfo()
		@attackResult
	
class Fight extends Backbone.Model
	constructor:(@player1,@player2)->
	attack:(attackPlayer,defensePlayer)->
		_attack = new Attack(attackPlayer,defensePlayer)
		_attack.attack()
	round:->
		@attack(@player1,@player2).isDead or @attack(@player2,@player1).isDead
	output:(player)->
		console.log('@'+player.name + '--' + player.constellation.name + ' win the fight!')
	begin:->
		isOver = false
		until isOver
			isOver = @round()
		if @player1.isDead()
			@output(@player2)
		if @player2.isDead()
			@output(@player1)
			
class Player extends Backbone.Model
	constructor: (personInfo,@constellation)->
		super personInfo
		@power = @get('power')
		@name = @get('name')
		@set {'hp':Math.floor(@power * @constellation.hp),'attack':Math.floor(@power*@constellation.attack)}
		
		if @constellation.isConstellationDate()
			@set {'isConstellationDate':true}
			@constellation.effect(this)
	defaults: ->
	 	{'power':100,'isConstellationDate':false}
	getSkillsByType:(type,timing)->
		skill for skill in @constellation.skills.concat(@skills) when skill.type is type and skill.timing is timing
	status:->
		console.log @name+' : '+@get('hp')
	isDead:->
		if @get('hp') <=0 then true else false
	setHp:(value)->
		value  or= @get('hp')
		@set {'hp':Math.floor(value)}
		this
	getHp:->
		@get('hp')
	addHp:(value)->
		@set {'hp':Math.floor(@get('hp')+value)}
		this
	resetHp:->
		@set {'hp':Math.floor(@power * @constellation.hp)}
	getAttack:->
		@get 'attack'
	skills:[
		new Hit()
	]
	effects:[]

handle = (data)->
	persons = JSON.parse(data)
	mock=->
		p1 = new Player(persons[3],new Libra())
		p2 = new Player(persons[4],new Scorpio())
		p3 = new Player(persons[5],new Taurus())
		fight = new Fight(p3,p2)
		fight.begin()
		
	mock()
#	mock() for i in [0...30]

$(->
	$.get '/friends',handle
#	handle(data)
)