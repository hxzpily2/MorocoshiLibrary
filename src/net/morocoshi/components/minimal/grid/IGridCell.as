package net.morocoshi.components.minimal.grid 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public interface IGridCell 
	{
		function get gridItem():DataGridItem;
		function set gridItem(value:DataGridItem):void;
		function get cellValue():*;
		function set cellValue(value:*):void;
	}
}