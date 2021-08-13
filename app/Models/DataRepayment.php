<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DataRepayment extends Model
{
    protected $table='data_repayments';

    public $incrementing = false;
    public $fillable = ['id','member_id','bank_id','branch_id','customer_name','product_id','tgl_pelunasan','keterangan','nominal_pengajuan'];
    // public $fillable = ['id','member_id'];

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

    function repayment_status() {
        return $this->belongsTo('App\Models\MasterRepaymentStatus');
    }

}
