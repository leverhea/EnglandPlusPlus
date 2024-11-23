-- EnglandPlusPlus
-- Author: leverhea
-- DateCreated: 11/19/2024 9:53:37 PM
--------------------------------------------------------------
UPDATE TraitModifiers
	SET ModifierId = 'GREATPERSON_EXTRA_TRADE_ROUTE_CAPACITY'
	WHERE ModifierId = 'TRAIT_FOREIGN_CONTINENT_MELEE_UNIT'
;


DELETE FROM Modifiers
	WHERE	ModifierId = 'TRAIT_FOREIGN_CONTINENT_MELEE_UNIT'
;


DELETE FROM ModifierArguments
	WHERE	ModifierId = 'TRAIT_FOREIGN_CONTINENT_MELEE_UNIT'
;


DELETE FROM DynamicModifiers
	WHERE	ModifierType = 'MODIFIER_PLAYER_ADJUST_SETTLE_FOREIGN_CONTINENT_UNIT_CLASS'
;

