# policevehicle
This is a script where you can buy police cars and put them in your garage.
this has been tested and works with qbcore
it only works with ranks not grades
It also has a discord webhook


## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- A target resource — either of:
  - [ox_target](https://github.com/TheOrderFivem/ox_target) (qb-core compatible fork)
  - [qb-target](https://github.com/qbcore-framework/qb-target)

## Target configuration

Both `ox_target` and `qb-target` are supported. Pick one in `config.lua`:

```lua
Config.Target = 'auto' -- 'auto' | 'ox_target' | 'qb-target'
```

`auto` detects whichever target resource is running, preferring `ox_target`
when both are started.


![image](https://github.com/user-attachments/assets/ad4c4cfc-6c68-4f59-bf2f-e824c438c8c0)
![image](https://github.com/user-attachments/assets/863d138f-c894-42e8-8f05-2cf3e06f04b6)
![image](https://github.com/user-attachments/assets/2e22f2e5-f53f-4004-a04e-4426c9a37df8)

