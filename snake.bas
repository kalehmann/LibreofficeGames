REM  *****  BASIC  *****

Type Parameters
	arena_x as Integer
	arena_y as Integer
	arena_width as Integer
	arena_height as Integer
	snake_start_x as Integer
	snake_start_y as Integer
	delay as Integer
	snake_color(2) as Integer
	bounty_color(2) as Integer
	arena_color(2) as Integer
End Type

Type SnakeDirection
	x as Integer
	y as Integer
End Type

Type SnakeSegment
	x as Integer
	y as Integer
End Type

Type Snake
	stack(32)
	len as Integer
	dir as SnakeDirection
	target as SnakeSegment
	do_free as Boolean
	free_seg as SnakeSegment
End Type

Type Bounty
	x as Integer
	y as Integer
End Type

Type Context
	params as Parameters
	snake as Snake
	bounty as Bounty
	score as Integer
End Type

REM Erstelle die globale Context-Variable
Dim ctx as Context

Sub Main

End Sub

Sub Start
	Randomize
	ctx.score = -1
	loadParameters
	drawArena
	createSnake
	placeBounty

	do while isNoCollision()
		updateSnake
		drawSnake
		drawBounty
		wait(ctx.params.delay)
	loop
	Randomize
End Sub

Sub increaseScore
	ctx.score = ctx.score + 1
	sheet = thisComponent.sheets(0)
	cell = sheet.getCellByPosition(28, 0)
	cell.value = ctx.score
End Sub


Sub drawSnake
	sheet = thisComponent.sheets(0)
	snakeColor = RGB(ctx.params.snake_color(0), ctx.params.snake_color(1),ctx.params.snake_color(2))
	For i=0 to ctx.snake.len-1
		seg = ctx.snake.stack(i)
		x = seg.x + ctx.params.arena_x + 1
		y = seg.y + ctx.params.arena_y + 1
		cell = sheet.getCellByPosition(x, y)
		cell.CellBackColor = snakeColor
	Next i
	if ctx.snake.do_free = True then
		free_seg = ctx.snake.free_seg
		x = free_seg.x + ctx.params.arena_x + 1
		y = free_seg.y + ctx.params.arena_y + 1
		cell = sheet.getCellByPosition(x, y)
		cell.IsCellBackgroundTRansparent = True
	end if
End Sub

Function isNoCollision() as Boolean
	Dim collision as Boolean
	collision = doesSnakeCollideArena() OR doesSnakeCollideSelf()
	isNoCollision = NOT collision
End Function

Function doesSnakeCollideArena() as Boolean
	w = ctx.params.arena_width
	h = ctx.params.arena_height
	if ctx.snake.target.x < 0 then
		doesSnakeCollideArena = True
	elseif ctx.snake.target.y < 0 then
		doesSnakeCollideArena = True
	elseif ctx.snake.target.x >= w then
		doesSnakeCollideArena = True 
	elseif ctx.snake.target.y >= h then
		doesSnakeCollideArena = True
	else
		doesSnakeCollideArena = False
	end if
End Function


Function doesSnakeCollideSelf() as Boolean
	doesSnakeCollideSelf = False
	for i=0 to ctx.snake.len-1
		seg = ctx.snake.stack(i)
		if seg.x = ctx.snake.target.x AND seg.y = ctx.snake.target.y then
			doesSnakeCollideSelf = True
		end if
	next i
End Function

Sub drawBounty
	b = ctx.bounty
	x = ctx.params.arena_x
	y = ctx.params.arena_y
	color = RGB(ctx.params.bounty_color(0), ctx.params.bounty_color(1),ctx.params.bounty_color(2))
	cell = thisComponent.sheets(0).getCellByPosition(b.x + x + 1, b.y + y + 1)
	cell.CellBackColor = color
End Sub

Sub placeBounty
	increaseScore
	w = ctx.params.arena_width
	h = ctx.params.arena_height
	stack = ctx.snake.stack
	Dim isNotOkay as Boolean
	isNotOkay = True
	do while isNotOkay
		x = INT(RND * (w-1))
		y = INT(RND * (h-1))
		isNotOkay = False
		for i=0 to ctx.snake.len - 1
			seg = stack(i)
			if x = seg.x AND y = seg.y then
				isNotOkay = True
			end if 
		next i
	loop
	
	ctx.bounty.x = x
	ctx.bounty.y = y
	
End Sub

Sub updateSnake
	bounty = ctx.bounty
	
	if ctx.snake.target.x = bounty.x AND ctx.snake.target.y = bounty.y then
		ctx.snake.do_free = False
		Dim seg as new SnakeSegment
		seg.x = bounty.x
		seg.y = bounty.y
		ctx.snake.stack(ctx.snake.len) = seg
		ctx.snake.len = ctx.snake.len + 1
		placeBounty
	else
		ctx.snake.do_free = True
		ctx.snake.free_seg.x = ctx.snake.stack(0).x
		ctx.snake.free_seg.y = ctx.snake.stack(0).y
		for i=0 to ctx.snake.len-1
			seg = ctx.snake.stack(i)
			if i<ctx.snake.len-1 then
				next_seg = ctx.snake.stack(i+1)
				seg.x = next_seg.x
				seg.y = next_seg.y
			else
				seg.x = ctx.snake.target.x
				seg.y = ctx.snake.target.y
			end if
		next i
	end if
	ctx.snake.target.x = ctx.snake.target.x + ctx.snake.dir.x
	ctx.snake.target.y = ctx.snake.target.y + ctx.snake.dir.y
End Sub

Sub createSnake
	Dim snake as new Snake
	snake.len = 2
	snake.dir.x = 1
	snake.dir.y = 0
	
	Dim seg1 as new SnakeSegment
	Dim seg2 as new SnakeSegment
	seg1.x = ctx.params.snake_start_x - 1
	seg1.y = ctx.params.snake_start_y
	seg2.x = ctx.params.snake_start_x
	seg2.y = ctx.params.snake_start_y
	
	snake.stack(0) = seg1
	snake.stack(1) = seg2
	
	snake.target.x = ctx.params.snake_start_x + 1
	snake.target.y = ctx.params.snake_start_y
	
	snake.do_free = False
	
	ctx.snake = snake
End Sub

Sub drawArena
	sheet = thisComponent.sheets(0)
	arena_color = RGB(ctx.params.arena_color(0), ctx.params.arena_color(1),ctx.params.arena_color(2))
	x = ctx.params.arena_x
	y = ctx.params.arena_y
	w = ctx.params.arena_width
	h = ctx.params.arena_height
	
	For i=x to x+w+1
		sheet.getCellByPosition(i, y).CellBackColor = arena_color
		sheet.getCellByPosition(i, y+h+1).CellBackColor = arena_color
	Next i
	For i=y+1 to y+h
		sheet.getCellByPosition(x, i).CellBackColor = arena_color
		sheet.getCellByPosition(x+w+1, i).CellBackColor = arena_color
	Next i
	For i=x+1 to x+w
		For j=y+1 to y+h
			sheet.getCellByPosition(i, j).IsCellBackgroundTransparent=True
		Next j
	Next i
End Sub
	
Sub loadParameters
	sheet = thisComponent.sheets(0)
	arena_x = sheet.getCellByPosition(1, 3)
	arena_y = sheet.getCellByPosition(1, 4)
	arena_width = sheet.getCellByPosition(1, 5)
	arena_height = sheet.getCellByPosition(1, 6)
	snake_start_x = sheet.getCellByPosition(1, 7)
	snake_start_y = sheet.getCellByPosition(1, 8)
	delay = sheet.getCellByPosition(1, 9)
	snake_color_R = sheet.getCellByPosition(1, 10)
	snake_color_G = sheet.getCellByPosition(2, 10)
	snake_color_B = sheet.getCellByPosition(3, 10)
	arena_color_R = sheet.getCellByPosition(1, 11)
	arena_color_G = sheet.getCellByPosition(2, 11)
	arena_color_B = sheet.getCellByPosition(3, 11)
	bounty_color_R = sheet.getCellByPosition(1, 12)
	bounty_color_G = sheet.getCellByPosition(2, 12)
	bounty_color_B = sheet.getCellByPosition(3, 12)
	
	Dim params as new Parameters
	
	params.arena_x = arena_x.value
	params.arena_y = arena_y.value
	params.arena_width = arena_width.value
	params.arena_height = arena_height.value
	params.snake_start_x = snake_start_x.value
	params.snake_start_y = snake_start_y.value
	params.delay = delay.value
	params.snake_color(0) = snake_color_R.value
	params.snake_color(1) = snake_color_G.value
	params.snake_color(2) = snake_color_B.value
	params.arena_color(0) = arena_color_R.value
	params.arena_color(1) = arena_color_G.value
	params.arena_color(2) = arena_color_B.value
	params.bounty_color(0) = bounty_color_R.value
	params.bounty_color(1) = bounty_color_G.value
	params.bounty_color(2) = bounty_color_B.value
	
	ctx.params = params
End Sub

Sub onKeyUp
	if ctx.snake.dir.y = 0 then
		ctx.snake.dir.y = -1
		ctx.snake.dir.x = 0
	end if
End Sub

Sub onKeyDown
	if ctx.snake.dir.y = 0 then
		ctx.snake.dir.y = 1
		ctx.snake.dir.x = 0
	end if
End Sub

Sub onKeyLeft
	if ctx.snake.dir.x = 0 then
		ctx.snake.dir.x = -1
		ctx.snake.dir.y = 0
	end if
End Sub

Sub onKeyRight
	if ctx.snake.dir.x = 0 then
		ctx.snake.dir.x = 1
		ctx.snake.dir.y = 0
	end if
End Sub

Sub installShortcuts
    SetCommandShortcut( CreateKeyEvent( 0, com.sun.star.awt.Key.UP ), "vnd.sun.star.script:Standard.Snake.onKeyUp?language=Basic&location=document")
    SetCommandShortcut( CreateKeyEvent( 0, com.sun.star.awt.Key.DOWN ), "vnd.sun.star.script:Standard.Snake.onKeyDown?language=Basic&location=document")
    SetCommandShortcut( CreateKeyEvent( 0, com.sun.star.awt.Key.LEFT ), "vnd.sun.star.script:Standard.Snake.onKeyLeft?language=Basic&location=document")
    SetCommandShortcut( CreateKeyEvent( 0, com.sun.star.awt.Key.RIGHT ), "vnd.sun.star.script:Standard.Snake.onKeyRight?language=Basic&location=document")
End Sub

Sub uninstallShortcuts
	RemoveCOmmandShortcut("vnd.sun.star.script:Standard.Snake.onKeyUp?language=Basic&location=document")
	RemoveCOmmandShortcut("vnd.sun.star.script:Standard.Snake.onKeyDown?language=Basic&location=document")
	RemoveCOmmandShortcut("vnd.sun.star.script:Standard.Snake.onKeyLeft?language=Basic&location=document")
	RemoveCOmmandShortcut("vnd.sun.star.script:Standard.Snake.onKeyRight?language=Basic&location=document")
End Sub