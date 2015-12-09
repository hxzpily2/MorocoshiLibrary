package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SkinContainer extends Object3D 
	{
		
		/**このスキン内にあるボーンオブジェクトのリスト*/
		public var bones:Vector.<Bone>;
		public var skins:Vector.<Skin>;
		private var invertSkin:Matrix3D;
		
		public function SkinContainer() 
		{
			super();
			
			invertSkin = new Matrix3D();
			bones = new Vector.<Bone>;
			skins = new Vector.<Skin>;
		}
		
		/**
		 * スキンメッシュの現在の姿勢で境界ボックスを更新する。ボーンの初期姿勢からのずれで計算するため実際のメッシュより大きく設定される傾向にあります。
		 */
		public function updateSkinBounds(bones:Vector.<Bone>):void
		{
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateSkinBounds(bones);
			}
			skin = null;
		}
		
		override protected function calculate(collector:RenderCollector):void 
		{
			//スキン姿勢の逆行列の計算
			invertSkin.copyFrom(_worldMatrix);
			invertSkin.invert();
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateBoneConstants(invertSkin);
			}
			skin = null;
		}
		
		/**
		 * スキン内にあるボーンオブジェクトを収集して必要なシェーダーを生成する
		 */
		public function collectBones():void
		{
			bones.length = 0;
			skins.length = 0;
			
			var current:Object3D;
			var bone:Bone;
			
			var task:Vector.<Object3D> = new <Object3D>[this];
			while (task.length)
			{
				current = task.pop()._children;
				while (current)
				{
					if (current is Skin)
					{
						skins.push(current as Skin);
					}
					bone = current as Bone;
					if (bone && bone.hasWeight)
					{
						bones.push(bone);
					}
					task.push(current);
					current = current._next;
				}
			}
			
			task = null;
			current = null;
			bone = null;
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.createSkinShader(bones);
			}
			skin = null;
		}
		
		override public function finaly():void 
		{
			super.finaly();
			
			DataUtil.deleteVector(bones);
			DataUtil.deleteVector(skins);
			bones = null;
			skins = null;
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.referenceProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			//skin.rawBounds = rawBounds? rawBounds.clone() : null;
			skin = null;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			//skin.rawBounds = rawBounds? rawBounds.clone() : null;
			skin = null;
		}
		
		override public function clone():Object3D 
		{
			var skin:SkinContainer = new SkinContainer();
			
			cloneProperties(skin);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				skin.addChild(current.clone());
			}
			
			skin.collectBones();
			
			return skin;
		}
		
		override public function reference():Object3D 
		{
			var skin:SkinContainer = new SkinContainer();
			
			referenceProperties(skin);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				skin.addChild(current.reference());
			}
			
			skin.collectBones();
			
			return skin;
		}
		
	}

}