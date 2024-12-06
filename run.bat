@echo off
if [%3]==[] goto debug

if [%3]==[-speed] goto speed

:debug
@echo on
odin run src -debug -sanitize:address  -- %1 %2
@echo off
goto :done

:speed
@echo on
odin run src -o:speed  -- %1 %2
@echo off
goto :done

:done