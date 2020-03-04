include "startup/EP_Export.ms"

try
	(cui.UnRegisterDialogBar Exporter; DestroyDialog Exporter)catch()

-- EP_Export = filein "EP_Export.ms" --to be replaced with import

rollout Exporter "Exporter" width:104
( 
	checkbox chk_ExportCollision "Export Collision" checked:True
	button btn_Export "Export"
	label lbl_Space ""
	button btn_OpenFolder "Open Export Folder"
	
	
	on btn_Export pressed do
	(
		objarray = #()
		FBXExporterSetParam "SmoothingGroups" true
		for obj in selection do
		(
			parentNode = EP_Export.getParentNodes(obj)
			appendIfUnique objarray parentNode
		)
		
		for obj in objarray do 
		(
			if (matchpattern obj.name pattern:"*-*") then
			(
				messagebox("object name may not contain hyphens")
			)
			else 
			(
				childrenNodes = EP_Export.getChildrenNodes(obj)
				-- remove dummys from node collection
				for n=childrenNodes.count to 1 by -1 do
				(
					if classOf childrenNodes[n] == Dummy do
					(
						deleteitem childrenNodes n
					)
				)
				
				--Get original position and move to world zero
				orgPos = obj.pos
				obj.pos = [0,0,0]
				
				-- Uncheck Collision
				if chk_ExportCollision.checked then
				(
					EP_Export.selectObjArray childrenNodes 
				)
				else 
				(
					EP_Export.selectObjArray childrenNodes col:False
				)
				
				EP_Export.resetObjectXform(childrenNodes) -- Reset xform
				max unlink -- unlink from parents
				
				-- Export
				exportpath = maxfilepath + obj.name + ".FBX"
				exportFile exportpath #noPrompt selectedOnly:true
				print ("exported " + obj.name)
				max undo -- undo unlink from parents
				
				obj.pos = orgPos -- Restore to original position
			)
		)
	)
	on btn_OpenFolder pressed do
	(
		fp = maxfilepath
		cmd = "explorer " + fp
		doscommand cmd
		print cmd
	)
)

CreateDialog Exporter
cui.registerdialogbar Exporter style:#(#cui_dock_vert, #cui_floatable) 