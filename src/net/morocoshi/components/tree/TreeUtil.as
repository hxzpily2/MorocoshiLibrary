package net.morocoshi.components.tree
{
	/**
	 * TreeLimb関係の処理
	 * 
	 * @author	tencho
	 */
	public class TreeUtil
	{
		/**
		 * 複数のTreeLimbオブジェクトを破棄する
		 * @param	limbs
		 */
		static public function disposeLimbs(limbs:Vector.<TreeLimb>):void
		{
			var list:Vector.<TreeLimb> = limbs.concat();
			while (list.length)
			{
				list.pop().dispose();
			}
		}
		
		/**
		 * TreeLimbリストの中で親子関係のあるアイテムがあれば親だけを残して子は削除した新しい配列を返す
		 * @param	limbs
		 * @return
		 */
		static public function adjustFamily(limbs:Vector.<TreeLimb>):Vector.<TreeLimb>
		{
			var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
			for each(var limb1:TreeLimb in limbs)
			{
				var isMatch:Boolean = false;
				loop: for each(var limb2:TreeLimb in limbs)
				{
					if (limb1 == limb2) continue;
					if (limb1.checkAncestor(limb2))
					{
						isMatch = true;
						break loop;
					}
				}
				if (!isMatch) result.push(limb1);
			}
			return result;
		}
		
	}
	
}