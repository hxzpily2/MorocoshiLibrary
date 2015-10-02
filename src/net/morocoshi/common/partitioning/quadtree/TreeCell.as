package net.morocoshi.common.partitioning.quadtree 
{
	/**
	 * 四分木のセル
	 * 
	 * @author tencho
	 */
	public class TreeCell
	{
		/**リンクリストの先頭要素*/
		public var root:TreeData;
		/**四分木空間*/
		public var quadTree:QuadTree;
		
		public function TreeCell(tree:QuadTree) 
		{
			quadTree = tree;
		}
		
		public function push(data:TreeData):Boolean
		{
			//既に登録されていればスキップ
			if (data.cell == this) return false;
			if (!root)
			{
				root = data;
			}
			else
			{
				data.next = root;
				root.prev = data;
				root = data;
			}
			data.cell = this;
			return true;
		}
		
		public function remove(data:TreeData):Boolean 
		{
			if (root != data) return false;
			root = root.next;
			if(root) root.prev = null;
			return true;
		}
		
	}

}