package net.morocoshi.components.minimal 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.Label;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Bit101Util 
	{
		
		public function Bit101Util() 
		{
		}
		
		static public function adjustComboList(combo:ComboBox, max:Number = 10, openTop:Boolean = false):void 
		{
			combo.numVisibleItems = Math.max(1, Math.min(max, combo.items.length));
			combo.openPosition = openTop? "top" : "bottom";
		}
		
		static public function setLabelSelectable(label:Label, selectable:Boolean):void 
		{
			label.mouseChildren = selectable;
			label.mouseEnabled = selectable;
			label.textField.mouseEnabled = selectable;
			label.textField.selectable = selectable;
		}
		
		static public function setRect(target:Component, rect:Rectangle):void 
		{
			target.x = rect.x;
			target.y = rect.y;
			target.width = rect.width;
			target.height = rect.height;
		}
		
	}

}