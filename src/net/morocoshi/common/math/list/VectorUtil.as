package net.morocoshi.common.math.list
{
	import net.morocoshi.common.math.random.MT;
	/**
	 * Vector系処理
	 * 
	 * @author tencho
	 */
	public class VectorUtil
	{	
		/**
		 * 配列からアイテムを削除
		 * @param	vector	VectorかArray
		 * @param	item	削除するアイテム
		 * @return
		 */
		static public function deleteItem(vector:*, item:*):Boolean
		{
			var index:int = vector.indexOf(item);
			if (index == -1) return false;
			vector.splice(index, 1);
			return true;
		}
		
		/**
		 * 配列から複数のアイテムを削除
		 * @param	vector	VectorかArray
		 * @param	items	VectorかArray
		 * @return
		 */
		static public function deleteItemList(vector:*, items:*):void
		{
			for each(var item:* in items.concat())
			{
				deleteItem(vector, item);
			}
		}
		
		/**
		 * リストAにリストBの要素を追加する。
		 * @param	a
		 * @param	b
		 */
		static public function attachList(a:*, b:*):void
		{
			var n:int = b.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:* = b[i];
				a.push(item);
			}
		}
		
		/**
		 * リストAにリストBの要素を追加する。同じ要素が既にAにあれば追加しない。
		 * @param	a
		 * @param	b
		 */
		static public function attachListDiff(a:*, b:*):void
		{
			var n:int = b.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:* = b[i];
				if (a.indexOf(item) != -1) continue;
				a.push(item);
			}
		}
		
		/**
		 * リストAにアイテムBを追加する。同じ要素が既にAにあれば追加しない。
		 * @param	list
		 * @param	item
		 */
		static public function attachItemDiff(list:*, item:*):Boolean
		{
			var index:int = list.indexOf(item);
			if (index != -1) return false;
			list.push(item);
			return true;
		}
		
		static public function copy(from:*, to:*):void 
		{
			if (from === to) return;
			
			to.length = 0;
			var n:int = from.length;
			for (var i:int = 0; i < n; i++) 
			{
				to.push(from[i]);
			}
		}
		
		static public function shuffle(list:*):void 
		{
			var cloned:* = list.concat();
			list.length = 0;
			while (cloned.length) 
			{
				var start:int = Math.random() * cloned.length;
				var item:* = cloned.splice(start, 1)[0];
				list.push(item);
			}
		}
		
		static public function shuffleMT(list:*, seed:int):void 
		{
			var mt:MT = new MT();
			mt.initialize(seed);
			var cloned:* = list.concat();
			list.length = 0;
			while (cloned.length) 
			{
				var start:int = mt.random() * cloned.length;
				var item:* = cloned.splice(start, 1)[0];
				list.push(item);
			}
		}
		
		static public function toArray(vector:*):Array 
		{
			var result:Array = [];
			var n:int = vector.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.push(vector[i]);
			}
			return result;
		}
		
		/**
		 * valueと一致する値がlistの中にあるかチェックし、あればインデックスを返す。なければ-1を返す。
		 * @param	value	チェックする値
		 * @param	list	この配列内にあるか
		 * @return
		 */
		static public function search(value:*, list:*):int 
		{
			var n:int = list.length;
			for (var i:int = 0; i < n; i++)
			{
				if (list[i] === value) return i;
			}
			return -1;
		}
		
	}

}