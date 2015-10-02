package net.morocoshi.moja3d.renderer 
{
	/**
	 * ソートクラス
	 * 
	 * @author ...
	 */
	public class RenderElementSort 
	{
		
		private var temp:RenderElement = new RenderElement();
		
		public function RenderElementSort() 
		{
		}
		
		public function sortByAverageZ(list:RenderElement, direction:Boolean = true):RenderElement
		{
			var left:RenderElement = list;
			var right:RenderElement = list.next;
			
			while (right != null && right.next != null)
			{
				list = list.next;
				right = right.next.next;
			}
			right = list.next;
			list.next = null;
			if (left.next != null)
			{
				left = sortByAverageZ(left, direction);
			}
			if (right.next != null)
			{
				right = sortByAverageZ(right, direction);
			}
			var flag:Boolean = direction? (left.distance > right.distance) : (left.distance < right.distance);
			if (flag)
			{
				list = left;
				left = left.next;
			}
			else
			{
				list = right;
				right = right.next;
			}
			
			var last:RenderElement = list;
			while (true)
			{
				if (left == null)
				{
					last.next = right;
					return list;
				}
				else if (right == null)
				{
					last.next = left;
					return list;
				}
				
				if (flag)
				{
					if (direction ? (left.distance > right.distance) : (left.distance < right.distance))
					{
						last = left;
						left = left.next;
					}
					else
					{
						last.next = right;
						last = right;
						right = right.next;
						flag = false;
					}
				}
				else
				{
					if (direction ? (left.distance < right.distance) : (left.distance > right.distance))
					{
						last = right;
						right = right.next;
					}
					else
					{
						last.next = left;
						last = left;
						left = left.next;
						flag = true;
					}
				}
			}
			return null;
		}
		
		public function sort(target:RenderElement):RenderElement
		{
			var length:int = target.getLength();
			if (length <= 1) return target;
			
			return msort(target, length);
		}
		
		private function msort(x:RenderElement, length:int):RenderElement
		{
			if (length == 1)
			{
				x.next = null;
				return x;
			}
			
			var half:int = length / 2;
			var y:RenderElement = x;
			for (var i:int = 0; i < half; i++) 
			{
				y = y.next;
			}
			
			var xlist:RenderElement = msort(x, half);
			var ylist:RenderElement = msort(y, length - half);
			
			var current:RenderElement = temp;
			while (xlist && ylist)
			{
				if (xlist.distance >= ylist.distance)
				{
					current.next = xlist;
					current = xlist;
					xlist = xlist.next;
				}
				else
				{
					current.next = ylist;
					current = ylist;
					ylist = ylist.next;
				}
			}
			current.next = xlist || ylist;
			return temp.next;
		}
		
	}

}