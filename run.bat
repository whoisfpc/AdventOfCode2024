@echo off
if [%3]==[] goto debug

if [%3]==[-speed] goto speed

:debug
echo run debug
odin run src -debug -sanitize:address  -- %1 %2
goto :done

:speed
echo run speed
odin run src -o:speed  -- %1 %2
goto :done

:done