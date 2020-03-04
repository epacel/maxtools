struct EP_Export
(
	fn getParentNodes theNode =
	(
		theParent = theNode.parent
		while (theParent != undefined) do
		(
			theNode = theParent
			theParent = theNode.parent
		)
		
		print theNode
		return theNode
    ),
	
	fn getChildrenNodes nodes=
	(
		allnodes = #()
		for n in nodes do
		(
			append allnodes n
			childNodes = EP_Export.getChildrenNodes n.children
			for cN in childNodes do
			(
				appendIfUnique allnodes cN
			)
		)
		
		return allnodes
	),
	
	fn selectObjArray a col:True=
	(
		deselect $*
		print a
		for i in a do
		(
			if col == False then
			(
				n = i.name
				nn = substring n 1 3
				if nn != "UCX" and nn != "UBX" and nn != "USP" then
				(
					selectMore i
				)
			)
			else
			(
				selectMore i
			)
		)
	),
	
	fn resetObjectXform objectArray =
	(
		for o in objectArray  where classof o == Editable_Poly do
		(
			ResetXForm o
			macros.run "Modifier Stack" "Convert_to_Poly"
		)
	),
	
	fn duplicateNodes nodeArray =
	(
		
	),
	
	fn exportObj =
	(
		for obj in selection do deselect obj.children
		objarray = getCurrentSelection()
		exportedcount = 0

		for obj in objarray do 
		(
			if (matchpattern obj.name pattern:"*-*") then
			(
				messagebox("object name may not contain hyphens")
			)
			else 
			(
				--Get original position and move to world zero
				parentNode = EP_Export.getParentNodes (obj)
				
				childrenNodes = EP_Export.getChildrenNodes(parentNode)
				newNodes = maxOps.cloneNodes (childrenNodes) cloneType:#instance #nodialog
				
				orgPos = parentNode.pos
				parentNode.pos = [0,0,0]
				EP_Export.selectArray(childrenNodes)
				
				-- Reset xform
				EP_Export.resetObjectXform(childrenNodes)
				
				-- Export
				exportpath = maxfilepath + obj.name + ".FBX"
				exportFile exportpath #noPrompt selectedOnly:true
				print ("exported " + obj.name)
				
				-- Restore to original position
				parentNode.pos = orgPos
			)
		)
		
		redrawViews()  
	)
)