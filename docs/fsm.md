# Traffic Light Controller FSM

The controller uses a four-state Moore FSM for two road directions.

| State | Lane 1 | Lane 2 | Transition condition |
| --- | --- | --- | --- |
| `S0_G1_R2` | Green | Red | `timeout_yellow` |
| `S1_Y1_R2` | Yellow | Red | `timeout_total` |
| `S2_R1_G2` | Red | Green | `timeout_yellow` |
| `S3_R1_Y2` | Red | Yellow | `timeout_total` |

Manual modes override the automatic timing mode:

| Mode | Encoding | Behavior |
| --- | --- | --- |
| Normal | `2'b00` | Uses `P_TIME_NORM` as the full phase duration. |
| Rush hour | `2'b01` | Uses `P_TIME_RUSH` as the full phase duration. |
| Blink | `2'b10` | Pauses the counter and toggles both yellow lamps from `clk1`. |
| Hold | `2'b11` | Holds the current green phase and pauses the counter. |

Rush-hour mode is selected automatically from the BCD 24-hour clock during 07:00:00-09:00:00 and 17:00:00-19:00:00. Manual hold has higher priority than manual blink.
