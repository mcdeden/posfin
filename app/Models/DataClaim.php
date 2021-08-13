<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DataClaim extends Model
{
    protected $table='data_claims';

    public $incrementing = false;
    public $fillable = ['id','member_id','bank_id','branch_id','customer_name','product_id','nominal_pengajuan','tgl_meninggal','tgl_pengajuan','keterangan','nominal_dibayarkan'];

    function member() {
        return $this->belongsTo('App\Models\DataMember');
    }

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function branch() {
        return $this->belongsTo('App\Models\MasterBranch');
    }

    function product() {
        return $this->belongsTo('App\Models\MasterProduct');
    }

    function claim_status() {
        return $this->belongsTo('App\Models\MasterClaimStatus');
    }

    public function documents()
    {
        return $this->hasMany('App\Models\DataDocument','member_id','member_id');
    }

}
