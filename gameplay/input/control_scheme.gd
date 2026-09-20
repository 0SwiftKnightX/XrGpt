class_name XRGptControlScheme
extends Resource

## Canonical controller-input vocabulary for XrGpt.
## Gameplay systems should consume these names instead of hard-coding
## left/right controller behavior into individual abilities.

const LEFT_TRIGGER := "left_trigger"
const RIGHT_TRIGGER := "right_trigger"
const LEFT_GRIP := "left_grip"
const RIGHT_GRIP := "right_grip"

const A_BUTTON := "a_button"
const B_BUTTON := "b_button"
const X_BUTTON := "x_button"
const Y_BUTTON := "y_button"
const MENU_BUTTON := "menu_button"

const LEFT_STICK := "left_stick"
const RIGHT_STICK := "right_stick"
const LEFT_STICK_CLICK := "left_stick_click"
const RIGHT_STICK_CLICK := "right_stick_click"
const LEFT_STICK_TOUCH := "left_stick_touch"
const RIGHT_STICK_TOUCH := "right_stick_touch"
const LEFT_BUTTON_PAD_TOUCH := "left_button_pad_touch"
const RIGHT_BUTTON_PAD_TOUCH := "right_button_pad_touch"

const COMBO_LEFT_GRIP_TRIGGER := "left_grip+left_trigger"
const COMBO_RIGHT_GRIP_TRIGGER := "right_grip+right_trigger"
const COMBO_BOTH_GRIPS := "left_grip+right_grip"
const COMBO_BOTH_GRIPS_TRIGGERS := "left_grip+right_grip+left_trigger+right_trigger"
const COMBO_BOTH_TRIGGERS := "left_trigger+right_trigger"

const COMBO_A_LEFT_TRIGGER := "a_button+left_trigger"
const COMBO_A_RIGHT_TRIGGER := "a_button+right_trigger"
const COMBO_A_BOTH_TRIGGERS := "a_button+left_trigger+right_trigger"
const COMBO_X_LEFT_TRIGGER := "x_button+left_trigger"
const COMBO_X_RIGHT_TRIGGER := "x_button+right_trigger"
const COMBO_X_BOTH_TRIGGERS := "x_button+left_trigger+right_trigger"

## "Grip trigger" is game-facing shorthand only.
## The actual logic always names the hand-specific grip + trigger pair.
static func combo_for_grip_trigger(left_hand: bool) -> String:
	return COMBO_LEFT_GRIP_TRIGGER if left_hand else COMBO_RIGHT_GRIP_TRIGGER

## Canonical dual-hand activation input.
static func dual_hand_activation_combo() -> String:
	return COMBO_BOTH_GRIPS_TRIGGERS
